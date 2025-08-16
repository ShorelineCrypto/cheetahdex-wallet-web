import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/bloc/settings/settings_bloc.dart';
import 'package:web_dex/bloc/settings/settings_state.dart';
import 'package:web_dex/bloc/trading_status/trading_status_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/main_menu_value.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/router/state/routing_state.dart';
import 'package:web_dex/views/common/main_menu/main_menu_bar_mobile_item.dart';

class MainMenuBarMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainMenuValue selected = routingState.selectedMenu;
    final currentWallet = context.watch<AuthBloc>().state.currentUser?.wallet;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final bool isMMBotEnabled = state.mmBotSettings.isMMBotEnabled;
        final bool tradingEnabled =
            context.watch<TradingStatusBloc>().state is TradingEnabled;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.currentGlobal.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, -10),
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 75,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: MainMenuBarMobileItem(
                      value: MainMenuValue.wallet,
                      isActive: selected == MainMenuValue.wallet,
                    ),
                  ),
                  Expanded(
                    child: MainMenuBarMobileItem(
                      value: MainMenuValue.fiat,
                      enabled: currentWallet?.isHW != true,
                      isActive: selected == MainMenuValue.fiat,
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: tradingEnabled
                          ? ''
                          : LocaleKeys.tradingDisabledTooltip.tr(),
                      child: MainMenuBarMobileItem(
                        value: MainMenuValue.dex,
                        enabled: currentWallet?.isHW != true,
                        isActive: selected == MainMenuValue.dex,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: tradingEnabled
                          ? ''
                          : LocaleKeys.tradingDisabledTooltip.tr(),
                      child: MainMenuBarMobileItem(
                        value: MainMenuValue.bridge,
                        enabled: currentWallet?.isHW != true,
                        isActive: selected == MainMenuValue.bridge,
                      ),
                    ),
                  ),
                  if (isMMBotEnabled)
                    Expanded(
                      child: Tooltip(
                        message: tradingEnabled
                            ? ''
                            : LocaleKeys.tradingDisabledTooltip.tr(),
                        child: MainMenuBarMobileItem(
                          enabled: currentWallet?.isHW != true,
                          value: MainMenuValue.marketMakerBot,
                          isActive: selected == MainMenuValue.marketMakerBot,
                        ),
                      ),
                    ),
                  Expanded(
                    child: MainMenuBarMobileItem(
                      value: MainMenuValue.nft,
                      enabled: currentWallet?.isHW != true,
                      isActive: selected == MainMenuValue.nft,
                    ),
                  ),
                  Expanded(
                    child: MainMenuBarMobileItem(
                      value: MainMenuValue.settings,
                      isActive: selected == MainMenuValue.settings,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
