import 'package:flutter/material.dart';
import 'package:web_dex/views/nfts/common/widgets/nft_no_login.dart';

class NftNoChainsEnabled extends StatelessWidget {
  const NftNoChainsEnabled({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: const NftNoLogin(
            text: 'Please enable NFT protocol assets in the wallet. Enable chains like ETH, BNB, AVAX, MATIC, or FTM to view your NFTs.',
          ),
        ),
      ],
    );
  }
}
