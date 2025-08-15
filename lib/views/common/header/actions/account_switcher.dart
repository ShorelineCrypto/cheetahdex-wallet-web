import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/dispatchers/popup_dispatcher.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/shared/widgets/connect_wallet/connect_wallet_wrapper.dart';
import 'package:web_dex/shared/widgets/logout_popup.dart';
import 'package:web_dex/views/wallets_manager/wallets_manager_events_factory.dart';

const double minWidth = 100;
const double maxWidth = 350;

class AccountSwitcher extends StatefulWidget {
  const AccountSwitcher({Key? key}) : super(key: key);

  @override
  State<AccountSwitcher> createState() => _AccountSwitcherState();
}

class _AccountSwitcherState extends State<AccountSwitcher> {
  late PopupDispatcher _logOutPopupManager;
  bool _isOpen = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _logOutPopupManager = PopupDispatcher(
        context: scaffoldKey.currentContext ?? context,
        popupContent: LogOutPopup(
          onConfirm: () => _logOutPopupManager.close(),
          onCancel: () => _logOutPopupManager.close(),
        ),
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _logOutPopupManager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectWalletWrapper(
      buttonSize: const Size(160, 30),
      withIcon: true,
      eventType: WalletsManagerEventType.header,
      child: UiDropdown(
        isOpen: _isOpen,
        onSwitch: (isOpen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _isOpen = isOpen);
          });
        },
        switcher: const _AccountSwitcher(),
        dropdown: _AccountDropdown(
          onTap: () {
            _logOutPopupManager.show();
            setState(() {
              _isOpen = false;
            });
          },
        ),
      ),
    );
  }
}

class _AccountSwitcher extends StatelessWidget {
  const _AccountSwitcher();

  @override
  Widget build(BuildContext context) {
    final currentWallet = context.read<AuthBloc>().state.currentUser?.wallet;
    return Container(
      constraints: const BoxConstraints(minWidth: minWidth),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<AuthBloc, AuthBlocState>(
            builder: (context, state) {
              return Container(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Text(
                  currentWallet?.name ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          const _AccountIcon(),
        ],
      ),
    );
  }
}

class _AccountDropdown extends StatelessWidget {
  final VoidCallback onTap;
  const _AccountDropdown({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: theme.custom.specificButtonBorderColor,
        ),
      ),
      constraints: const BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.fromLTRB(12, 0, 22, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  LocaleKeys.logOut.tr(),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountIcon extends StatelessWidget {
  const _AccountIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.tertiary),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SvgPicture.asset(
          '$assetsPath/ui_icons/account.svg',
          colorFilter: ColorFilter.mode(
            theme.custom.headerFloatBoxColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
