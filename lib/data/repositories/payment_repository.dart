import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/payment_models.dart';

/// Payment methods and charges against the ELK backend.
///
/// Backend contract:
///  * `GET  /payments/methods` → wallet/card/upi/cash (the wallet subLabel
///    carries the live balance)
///  * `POST /payments/charge { methodId, amount, promoCode? }` →
///    `{ reference }` — the wallet method debits the real balance, the
///    others are mock charges until a gateway exists
class PaymentRepository {
  PaymentRepository(this._client);

  final ApiClient _client;

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final data = await _client.get(ApiEndpoints.paymentMethods) as List;
    return data
        .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Charges [amount] using [methodId] and returns the transaction reference.
  Future<String> pay({
    required String methodId,
    required double amount,
    String? promoCode,
  }) async {
    final data = await _client.post(ApiEndpoints.paymentCharge, data: {
      'methodId': methodId,
      'amount': amount,
      'promoCode': ?promoCode,
    });
    return (data as Map<String, dynamic>)['reference'] as String;
  }
}
