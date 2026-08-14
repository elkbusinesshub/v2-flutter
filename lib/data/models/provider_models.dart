import 'payment_models.dart';

/// Provider card shown in "Best Sellers" carousel on Home.
class ProviderModel {
  const ProviderModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.category,
    required this.priceLabel,
    required this.rating,
    required this.colorHex,
    this.verified = true,
  });

  final String id;
  final String name;
  final String initials;
  final String category;
  final String priceLabel;
  final double rating;
  final int colorHex;
  final bool verified;

  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
        id: json['id'] as String,
        name: json['name'] as String,
        initials: json['initials'] as String,
        category: json['category'] as String,
        priceLabel: json['priceLabel'] as String,
        rating: (json['rating'] as num).toDouble(),
        colorHex: json['colorHex'] as int,
        verified: json['verified'] as bool? ?? true,
      );
}

/// Stat card on Provider Dashboard (Active Orders, Earnings, Rating).
class ProviderStatModel {
  const ProviderStatModel({
    required this.label,
    required this.value,
    required this.trend,
  });

  final String label;
  final String value;
  final String trend;
}

/// A weekday availability cell on the Provider Schedule screen.
class ScheduleDayModel {
  const ScheduleDayModel({
    required this.label,
    required this.available,
    required this.isToday,
  });

  final String label;
  final bool available;
  final bool isToday;
}

/// A time-slot row on the Provider Schedule screen.
class ScheduleSlotModel {
  const ScheduleSlotModel({
    required this.timeRange,
    required this.status,
  });

  final String timeRange;
  final ScheduleSlotStatus status;
}

enum ScheduleSlotStatus { active, pending, available }

/// Summary card pair on Provider Earnings screen.
class EarningsSummaryModel {
  const EarningsSummaryModel({
    required this.totalEarnings,
    required this.monthLabel,
    required this.trendLabel,
    required this.completedJobs,
    required this.completedJobsTrend,
    required this.avgPerJob,
    required this.avgPerJobTrend,
    required this.transactions,
  });

  final double totalEarnings;
  final String monthLabel;
  final String trendLabel;
  final int completedJobs;
  final String completedJobsTrend;
  final double avgPerJob;
  final String avgPerJobTrend;
  final List<WalletTransactionModel> transactions;

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) =>
      EarningsSummaryModel(
        totalEarnings: (json['totalEarnings'] as num).toDouble(),
        monthLabel: json['monthLabel'] as String,
        trendLabel: json['trendLabel'] as String,
        completedJobs: json['completedJobs'] as int,
        completedJobsTrend: json['completedJobsTrend'] as String,
        avgPerJob: (json['avgPerJob'] as num).toDouble(),
        avgPerJobTrend: json['avgPerJobTrend'] as String,
        transactions: (json['transactions'] as List)
            .map((e) =>
                WalletTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Aggregated payload for the Provider Dashboard screen.
class ProviderDashboardModel {
  const ProviderDashboardModel({
    required this.businessName,
    required this.modeLabel,
    required this.isAvailable,
    required this.stats,
  });

  final String businessName;
  final String modeLabel;
  final bool isAvailable;
  final List<ProviderStatModel> stats;

  factory ProviderDashboardModel.fromJson(Map<String, dynamic> json) =>
      ProviderDashboardModel(
        businessName: json['businessName'] as String,
        modeLabel: json['modeLabel'] as String,
        isAvailable: json['isAvailable'] as bool,
        stats: (json['stats'] as List)
            .map((e) => ProviderStatModel(
                  label: e['label'] as String,
                  value: e['value'] as String,
                  trend: e['trend'] as String,
                ))
            .toList(),
      );
}

/// Aggregated payload for the Provider Schedule screen.
class ProviderScheduleModel {
  const ProviderScheduleModel({
    required this.todaysBookingsCount,
    required this.days,
    required this.slots,
  });

  final int todaysBookingsCount;
  final List<ScheduleDayModel> days;
  final List<ScheduleSlotModel> slots;

  factory ProviderScheduleModel.fromJson(Map<String, dynamic> json) =>
      ProviderScheduleModel(
        todaysBookingsCount: json['todaysBookingsCount'] as int,
        days: (json['days'] as List)
            .map((e) => ScheduleDayModel(
                  label: e['label'] as String,
                  available: e['available'] as bool,
                  isToday: e['isToday'] as bool,
                ))
            .toList(),
        slots: (json['slots'] as List)
            .map((e) => ScheduleSlotModel(
                  timeRange: e['timeRange'] as String,
                  status: ScheduleSlotStatus.values.byName(e['status'] as String),
                ))
            .toList(),
      );
}

/// Registration form payload for the multi-step provider sign-up flow.
class ProviderRegistrationModel {
  const ProviderRegistrationModel({
    required this.businessName,
    required this.serviceCategory,
    required this.contactNumber,
    required this.serviceArea,
    required this.tradeLicenseUploaded,
    required this.idDocumentUploaded,
  });

  final String businessName;
  final String serviceCategory;
  final String contactNumber;
  final String serviceArea;
  final bool tradeLicenseUploaded;
  final bool idDocumentUploaded;

  ProviderRegistrationModel copyWith({
    String? businessName,
    String? serviceCategory,
    String? contactNumber,
    String? serviceArea,
    bool? tradeLicenseUploaded,
    bool? idDocumentUploaded,
  }) => ProviderRegistrationModel(
        businessName: businessName ?? this.businessName,
        serviceCategory: serviceCategory ?? this.serviceCategory,
        contactNumber: contactNumber ?? this.contactNumber,
        serviceArea: serviceArea ?? this.serviceArea,
        tradeLicenseUploaded: tradeLicenseUploaded ?? this.tradeLicenseUploaded,
        idDocumentUploaded: idDocumentUploaded ?? this.idDocumentUploaded,
      );

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'serviceCategory': serviceCategory,
        'contactNumber': contactNumber,
        'serviceArea': serviceArea,
        'tradeLicenseUploaded': tradeLicenseUploaded,
        'idDocumentUploaded': idDocumentUploaded,
      };
}
