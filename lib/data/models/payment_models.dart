class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.colorHex,
  });

  final String id;
  final String icon;
  final String label;
  final String subLabel;
  final int colorHex;

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        id: json['id'] as String,
        icon: json['icon'] as String,
        label: json['label'] as String,
        subLabel: json['subLabel'] as String,
        colorHex: json['colorHex'] as int,
      );
}

class CheckoutModel {
  const CheckoutModel({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.methods,
    required this.appliedPromoCode,
  });

  final String title;
  final double amount;
  final String subtitle;
  final List<PaymentMethodModel> methods;
  final String? appliedPromoCode;
}

/// A wallet transaction line item.
class WalletTransactionModel {
  const WalletTransactionModel({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.colorHex,
  });

  final String icon;
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final int colorHex;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        icon: json['icon'] as String,
        title: json['title'] as String,
        date: json['date'] as String,
        amount: (json['amount'] as num).toDouble(),
        isCredit: json['isCredit'] as bool,
        colorHex: json['colorHex'] as int,
      );
}

class WalletSummaryModel {
  const WalletSummaryModel({
    required this.balance,
    required this.rewardPoints,
    required this.transactions,
  });

  final double balance;
  final int rewardPoints;
  final List<WalletTransactionModel> transactions;

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) =>
      WalletSummaryModel(
        balance: (json['balance'] as num).toDouble(),
        rewardPoints: json['rewardPoints'] as int,
        transactions: (json['transactions'] as List)
            .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
