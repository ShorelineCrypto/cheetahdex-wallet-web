import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/coins_bloc/coins_repo.dart';
import 'package:web_dex/bloc/analytics/analytics_bloc.dart';
import 'package:web_dex/bloc/custom_token_import/bloc/custom_token_import_bloc.dart';
import 'package:web_dex/bloc/custom_token_import/bloc/custom_token_import_event.dart';
import 'package:web_dex/bloc/custom_token_import/data/custom_token_import_repository.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/views/custom_token_import/custom_token_import_dialog.dart';

class CustomTokenImportButton extends StatelessWidget {
  const CustomTokenImportButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UiPrimaryButton(
      onPressed: () {
        final coinsRepo = RepositoryProvider.of<CoinsRepo>(context);
        final kdfSdk = RepositoryProvider.of<KomodoDefiSdk>(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BlocProvider<CustomTokenImportBloc>(
              create: (context) => CustomTokenImportBloc(
                KdfCustomTokenImportRepository(kdfSdk, coinsRepo),
                coinsRepo,
                kdfSdk,
                context.read<AnalyticsBloc>(),
              )..add(const ResetFormStatusEvent()),
              child: const CustomTokenImportDialog(),
            );
          },
        );
      },
      child: Text(LocaleKeys.importCustomToken.tr()),
    );
  }
}
