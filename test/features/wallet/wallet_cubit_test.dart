import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/payment_models.dart';
import 'package:elk/data/repositories/wallet_repository.dart';
import 'package:elk/features/wallet/cubit/wallet_cubit.dart';

WalletTransactionModel _txn(String title, double amount, bool isCredit) =>
    WalletTransactionModel(
      icon: isCredit ? '💳' : '💸',
      title: title,
      date: 'Today',
      amount: amount,
      isCredit: isCredit,
      colorHex: 0xffd1fae5,
    );

/// Mirrors the backend: a mutation moves the balance *and* appends a row.
class _FakeWalletRepository implements WalletRepository {
  double balance = 250;
  List<WalletTransactionModel> transactions = [_txn('Payment', 85, false)];

  Object? summaryError;
  Object? mutationError;
  final List<String> calls = [];

  @override
  Future<WalletSummaryModel> getWalletSummary() async {
    calls.add('summary');
    if (summaryError != null) throw summaryError!;
    return WalletSummaryModel(
      balance: balance,
      rewardPoints: 120,
      transactions: transactions,
    );
  }

  @override
  Future<double> addMoney(double amount) async {
    calls.add('top-up:$amount');
    if (mutationError != null) throw mutationError!;
    balance += amount;
    transactions = [_txn('Wallet Top-up', amount, true), ...transactions];
    return balance;
  }

  @override
  Future<double> withdraw(double amount) async {
    calls.add('withdraw:$amount');
    if (mutationError != null) throw mutationError!;
    balance -= amount;
    transactions = [_txn('Wallet Withdrawal', amount, false), ...transactions];
    return balance;
  }
}

void main() {
  late _FakeWalletRepository repository;

  Future<WalletCubit> buildCubit({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return WalletCubit(repository, preferences);
  }

  setUp(() => repository = _FakeWalletRepository());

  test('loads balance, points and history', () async {
    final cubit = await buildCubit();
    await cubit.loadWallet();

    expect(cubit.state.status, WalletStatus.loaded);
    expect(cubit.state.summary!.balance, 250);
    expect(cubit.state.summary!.rewardPoints, 120);
    expect(cubit.state.summary!.transactions, hasLength(1));
  });

  test('guest mode short-circuits before hitting the API', () async {
    repository.summaryError = StateError('must not be called');
    final cubit = await buildCubit(values: {'is_guest': true});
    await cubit.loadWallet();

    expect(cubit.state.status, WalletStatus.guest);
    expect(repository.calls, isEmpty);
  });

  test('top-up refetches so the new transaction shows up', () async {
    final cubit = await buildCubit();
    await cubit.loadWallet();

    final message = await cubit.addMoney(100);
    expect(message, 'Wallet topped up');
    expect(cubit.state.summary!.balance, 350);
    // The history must come from the server, not a local balance patch.
    expect(cubit.state.summary!.transactions.first.title, 'Wallet Top-up');
    expect(repository.calls, ['summary', 'top-up:100.0', 'summary']);
    expect(cubit.state.isProcessing, isFalse);
  });

  test('withdrawal refetches too', () async {
    final cubit = await buildCubit();
    await cubit.loadWallet();

    final message = await cubit.withdraw(50);
    expect(message, 'Withdrawal successful');
    expect(cubit.state.summary!.balance, 200);
    expect(cubit.state.summary!.transactions.first.title, 'Wallet Withdrawal');
  });

  test('an insufficient balance returns the backend message and changes nothing',
      () async {
    final cubit = await buildCubit();
    await cubit.loadWallet();
    repository.mutationError = const ApiException(
      // 402 keeps the backend's own message — see ApiException.fromStatus.
      ApiErrorType.unknown,
      'Insufficient wallet balance',
    );

    final message = await cubit.withdraw(9999);
    expect(message, 'Insufficient wallet balance');
    expect(cubit.state.summary!.balance, 250);
    expect(cubit.state.isProcessing, isFalse);
  });

  test('a failed refetch keeps the wallet that was already on screen', () async {
    final cubit = await buildCubit();
    await cubit.loadWallet();
    repository.summaryError = const ApiException(ApiErrorType.network, 'No internet connection.');

    // The top-up itself succeeds; only the refresh fails.
    final message = await cubit.addMoney(100);
    expect(message, 'Wallet topped up');
    expect(cubit.state.status, WalletStatus.loaded);
    expect(cubit.state.summary, isNotNull);
  });

  test('mutating before the wallet has loaded is refused', () async {
    final cubit = await buildCubit();
    final message = await cubit.addMoney(100);

    expect(message, contains('still loading'));
    expect(repository.calls, isEmpty);
  });

  test('surfaces a friendly error when the summary fails', () async {
    repository.summaryError =
        const ApiException(ApiErrorType.network, 'No internet connection.');
    final cubit = await buildCubit();
    await cubit.loadWallet();

    expect(cubit.state.status, WalletStatus.error);
    expect(cubit.state.errorMessage, contains('internet'));
  });

  test('WalletSummaryModel parses the backend payload', () {
    final model = WalletSummaryModel.fromJson({
      'balance': 250.5,
      'rewardPoints': 120,
      'transactions': [
        {
          'icon': '💳',
          'title': 'Wallet Top-up',
          'date': 'Today',
          'amount': 100,
          'isCredit': true,
          'colorHex': 0xffd1fae5,
        },
      ],
    });

    expect(model.balance, 250.5);
    expect(model.rewardPoints, 120);
    expect(model.transactions.single.isCredit, isTrue);
    expect(model.transactions.single.amount, 100);
  });
}
