import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/bloc/coins_bloc/coins_repo.dart';
import 'package:web_dex/bloc/nft_transactions/bloc/nft_transactions_bloc.dart';
import 'package:web_dex/bloc/nft_transactions/nft_txn_repository.dart';
import 'package:web_dex/bloc/nfts/nft_main_repo.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/views/nfts/nft_transactions/desktop/nft_txn_desktop_page.dart.dart';
import 'package:web_dex/views/nfts/nft_transactions/mobile/nft_txn_mobile_page.dart';

class NftListOfTransactionsPage extends StatelessWidget {
  const NftListOfTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NftTransactionsBloc(
        nftTxnRepository: context.read<NftTxnRepository>(),
        nftsRepository: context.read<NftsRepo>(),
        coinsRepository: RepositoryProvider.of<CoinsRepo>(context),
        kdfSdk: RepositoryProvider.of<KomodoDefiSdk>(context),
        isLoggedIn: context.read<AuthBloc>().state.mode == AuthorizeMode.logIn,
      )..add(const NftTxnReceiveEvent()),
      child: isMobile ? const NftTxnMobilePage() : const NftTxnDesktopPage(),
    );
  }
}
