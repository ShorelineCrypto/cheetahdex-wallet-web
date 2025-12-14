import 'package:web_dex/mm2/mm2_api/rpc/base.dart';

class SendRawTransactionRequest implements BaseRequest {
  SendRawTransactionRequest({
    required this.coin,
    this.txHex,
    this.txJson,
  }) : assert(
          txHex != null || txJson != null,
          'Either txHex or txJson must be provided',
        );

  factory SendRawTransactionRequest.fromJson(Map<String, dynamic> json) {
    return SendRawTransactionRequest(
      coin: json['coin'],
      txHex: json['tx_hex'],
      txJson: json['tx_json'],
    );
  }

  @override
  final String method = 'send_raw_transaction';

  String coin;
  String? txHex;
  Map<String, dynamic>? txJson;

  @override
  late String userpass;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'coin': coin,
      if (txHex != null) 'tx_hex': txHex,
      if (txJson != null) 'tx_json': txJson,
      'userpass': userpass,
    };
  }
}
