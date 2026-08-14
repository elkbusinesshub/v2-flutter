/// What is left of the seller panel's fixture data.
///
/// Listings run on `GET /marketplace/my-ads` (Feature 34), orders on
/// `GET /marketplace/seller-orders` and notifications on `/notifications`
/// (Feature 37).
///
/// Only the **wallet** remains, and its list is deliberately empty: there is no
/// payout module on the backend, so anything here would be invented money the
/// seller cannot withdraw. The screen renders its empty state until that module
/// exists.
class SellerTransaction {
  const SellerTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });

  final String title, date, amount;
  final bool isCredit;
}

const sellerTransactions = <SellerTransaction>[];

/// Earnings chart series. Empty for the same reason.
const barData = <int>[];
const barDays = <String>[];
