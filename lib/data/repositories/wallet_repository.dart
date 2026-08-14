import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/payment_models.dart';

/// The ELK Wallet — balance, reward points and transaction history.
///
/// Backend contract:
///  * `GET  /wallet` → `{ balance, rewardPoints, transactions[] }`
///  * `POST /wallet/top-up  { amount }` → `{ balance }`
///  * `POST /wallet/withdraw { amount }` → `{ balance }`, or `402
///    INSUFFICIENT_BALANCE`
///
/// Both mutations also append a transaction row server-side, so callers
/// refetch the summary rather than patching the balance locally.
class WalletRepository {
  WalletRepository(this._client);

  final ApiClient _client;

  Future<WalletSummaryModel> getWalletSummary() async {
    final data = await _client.get(ApiEndpoints.wallet);
    return WalletSummaryModel.fromJson(data as Map<String, dynamic>);
  }

  Future<double> addMoney(double amount) async {
    final data = await _client.post(ApiEndpoints.walletTopUp, data: {'amount': amount});
    return ((data as Map<String, dynamic>)['balance'] as num).toDouble();
  }

  Future<double> withdraw(double amount) async {
    final data = await _client.post(ApiEndpoints.walletWithdraw, data: {'amount': amount});
    return ((data as Map<String, dynamic>)['balance'] as num).toDouble();
  }
}
