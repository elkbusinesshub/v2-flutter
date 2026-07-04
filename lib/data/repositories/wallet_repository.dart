import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/payment_models.dart';

class WalletRepository {
  WalletRepository(this._client);

  final ApiClient _client;

  Future<WalletSummaryModel> getWalletSummary() {
    return _client.simulate('/wallet', () {
      final json = dummyWalletSummaryJson;
      return WalletSummaryModel(
        balance: (json['balance'] as num).toDouble(),
        rewardPoints: json['rewardPoints'] as int,
        transactions: (json['transactions'] as List)
            .map((e) => WalletTransactionModel.fromJson(e))
            .toList(),
      );
    });
  }

  Future<double> addMoney(double amount) {
    return _client.simulateMutation(
      '/wallet/top-up',
      {'amount': amount},
      () => (dummyWalletSummaryJson['balance'] as num).toDouble() + amount,
    );
  }

  Future<double> withdraw(double amount) {
    return _client.simulateMutation(
      '/wallet/withdraw',
      {'amount': amount},
      () => (dummyWalletSummaryJson['balance'] as num).toDouble() - amount,
    );
  }
}
