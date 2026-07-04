import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/payment_models.dart';

class PaymentRepository {
  PaymentRepository(this._client);

  final ApiClient _client;

  Future<List<PaymentMethodModel>> getPaymentMethods() {
    return _client.simulate(
      '/payments/methods',
      () => dummyPaymentMethodsJson
          .map((e) => PaymentMethodModel.fromJson(e))
          .toList(),
    );
  }

  /// Charges [amount] using [methodId] and returns the transaction reference.
  Future<String> pay({
    required String methodId,
    required double amount,
    String? promoCode,
  }) {
    return _client.simulateMutation(
      '/payments/charge',
      {'methodId': methodId, 'amount': amount, 'promoCode': promoCode},
      () => '#ELK-2025-04921',
      delay: const Duration(milliseconds: 1200),
    );
  }
}
