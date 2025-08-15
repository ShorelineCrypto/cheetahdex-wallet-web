import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:web_dex/bloc/market_maker_bot/market_maker_bot/market_maker_bot_repository.dart';
import 'package:web_dex/bloc/market_maker_bot/market_maker_bot/market_maker_bot_status.dart';
import 'package:web_dex/bloc/market_maker_bot/market_maker_order_list/market_maker_bot_order_list_repository.dart';
import 'package:web_dex/bloc/settings/settings_repository.dart';
import 'package:web_dex/mm2/mm2_api/rpc/market_maker_bot/trade_coin_pair_config.dart';
import 'package:web_dex/mm2/mm2_api/rpc/rpc_error.dart';
import 'package:web_dex/mm2/mm2_api/rpc/rpc_error_type.dart';

part 'market_maker_bot_event.dart';
part 'market_maker_bot_state.dart';

/// BLoC responsible for starting, stopping and updating the market maker bot.
/// The bot is started with the parameters defined in the settings.
/// All active orders are cancelled when the bot is stopped or updated.
class MarketMakerBotBloc
    extends Bloc<MarketMakerBotEvent, MarketMakerBotState> {
  MarketMakerBotBloc(
    MarketMakerBotRepository marketMaketBotRepository,
    MarketMakerBotOrderListRepository orderRepository,
  )   : _botRepository = marketMaketBotRepository,
        _orderRepository = orderRepository,
        super(const MarketMakerBotState.initial()) {
    on<MarketMakerBotStartRequested>(
      _onStartRequested,
      transformer: restartable(),
    );
    on<MarketMakerBotStopRequested>(
      _onStopRequested,
      transformer: restartable(),
    );
    on<MarketMakerBotOrderUpdateRequested>(
      _onOrderUpdateRequested,
      transformer: sequential(),
    );
    on<MarketMakerBotOrderCancelRequested>(
      _onOrderCancelRequested,
      transformer: sequential(),
    );
  }

  final MarketMakerBotRepository _botRepository;
  final MarketMakerBotOrderListRepository _orderRepository;

  Future<void> _onStartRequested(
    MarketMakerBotStartRequested event,
    Emitter<MarketMakerBotState> emit,
  ) async {
    if (state.isRunning || state.isUpdating) {
      return;
    }

    emit(const MarketMakerBotState.starting());
    try {
      await _botRepository.start(botId: event.botId);
      emit(const MarketMakerBotState.running());
    } catch (e) {
      final isAlreadyStarted =
          e is RpcException && e.error.errorType == RpcErrorType.alreadyStarted;
      if (isAlreadyStarted) {
        emit(const MarketMakerBotState.running());
        return;
      }
      emit(const MarketMakerBotState.stopped().copyWith(error: e.toString()));
    }
  }

  Future<void> _onStopRequested(
    MarketMakerBotStopRequested event,
    Emitter<MarketMakerBotState> emit,
  ) async {
    try {
      emit(const MarketMakerBotState.stopping());
      await _botRepository.stop(botId: event.botId);
      await _waitForOrdersToBeCancelled(
        timeout: const Duration(minutes: 1),
        fatalTimeout: false,
      );
      emit(const MarketMakerBotState.stopped());
    } catch (e) {
      emit(
        const MarketMakerBotState.stopped()
            .copyWith(error: 'Failed to stop the bot'),
      );
    }
  }

  Future<void> _onOrderUpdateRequested(
    MarketMakerBotOrderUpdateRequested event,
    Emitter<MarketMakerBotState> emit,
  ) async {
    emit(const MarketMakerBotState.stopping());

    try {
      // Add the trade pair to stored settings immediately to provide feedback
      // and updates to the user.
      await _botRepository.addTradePairToStoredSettings(event.tradePair);

      // Cancel the order immediately to provide feedback to the user that
      // the bot is being updated, since the restart process may take some time.
      await _orderRepository.cancelOrders([event.tradePair]);
      final Stream<MarketMakerBotStatus> botStatusStream =
          _botRepository.updateOrder(event.tradePair, botId: event.botId);
      await for (final botStatus in botStatusStream) {
        emit(state.copyWith(status: botStatus));
      }
    } catch (e) {
      final isAlreadyStarted =
          e is RpcException && e.error.errorType == RpcErrorType.alreadyStarted;
      if (isAlreadyStarted) {
        emit(const MarketMakerBotState.running());
        return;
      }

      final stoppingState =
          const MarketMakerBotState.stopping().copyWith(error: e.toString());
      emit(stoppingState);
      await _botRepository.stop(botId: event.botId);
      emit(stoppingState.copyWith(status: MarketMakerBotStatus.stopped));
    }
  }

  Future<void> _onOrderCancelRequested(
    MarketMakerBotOrderCancelRequested event,
    Emitter<MarketMakerBotState> emit,
  ) async {
    emit(const MarketMakerBotState.stopping());

    try {
      await _orderRepository.cancelOrders(event.tradePairs.toList());

      final botStatusStream = _botRepository.cancelOrders(
        event.tradePairs,
        botId: event.botId,
      );
      await for (final botStatus in botStatusStream) {
        emit(state.copyWith(status: botStatus));
      }

      // Remove the trade pairs from the stored settings after the orders have
      // been cancelled to prevent the lag between the orders being cancelled
      // and the trade pairs being removed from the settings.
      await _botRepository
          .removeTradePairsFromStoredSettings(event.tradePairs.toList());
    } catch (e) {
      final isAlreadyStarted =
          e is RpcException && e.error.errorType == RpcErrorType.alreadyStarted;
      if (isAlreadyStarted) {
        emit(const MarketMakerBotState.running());
        return;
      }

      final stoppingState =
          const MarketMakerBotState.stopping().copyWith(error: e.toString());
      emit(stoppingState);
      await _botRepository.stop(botId: event.botId);
      emit(stoppingState.copyWith(status: MarketMakerBotStatus.stopped));
    }
  }

  /// Waits for all orders to be cancelled.
  ///
  /// Throws a [TimeoutException] if the orders are not cancelled in time if
  /// [fatalTimeout] is `true`. Otherwise, the function returns without throwing
  Future<void> _waitForOrdersToBeCancelled({
    Duration timeout = const Duration(seconds: 30),
    bool fatalTimeout = true,
  }) async {
    final start = DateTime.now();
    final orders = await _orderRepository.getTradePairs();
    while (orders.any((order) => order.order != null)) {
      if (DateTime.now().difference(start) > timeout) {
        if (fatalTimeout) {
          throw TimeoutException('Failed to cancel orders in time');
        }
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}
