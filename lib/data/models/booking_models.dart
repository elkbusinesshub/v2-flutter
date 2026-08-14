import 'package:intl/intl.dart';

import '../../core/l10n/l10n.dart';

/// A selectable date chip on the Booking screen.
class DateSlotModel {
  const DateSlotModel({
    required this.day,
    required this.weekday,
  });

  final int day;
  final String weekday;
}

/// A selectable time chip on the Booking screen.
class TimeSlotModel {
  const TimeSlotModel({
    required this.time,
    required this.available,
  });

  final String time;
  final bool available;
}

/// Pricing breakdown shown at the bottom of the Booking screen.
class PriceBreakdownModel {
  const PriceBreakdownModel({
    required this.serviceFee,
    required this.promoCode,
    required this.promoDiscount,
    required this.total,
  });

  final double serviceFee;
  final String? promoCode;
  final double promoDiscount;
  final double total;
}

/// Data shown on the Booking screen for a given service.
class BookingDetailsModel {
  const BookingDetailsModel({
    required this.serviceId,
    required this.serviceName,
    required this.dates,
    required this.timeSlots,
    required this.address,
    required this.pricing,
  });

  final String serviceId;
  final String serviceName;
  final List<DateSlotModel> dates;
  final List<TimeSlotModel> timeSlots;
  final String address;
  final PriceBreakdownModel pricing;

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) =>
      BookingDetailsModel(
        serviceId: json['serviceId'] as String,
        serviceName: json['serviceName'] as String,
        dates: (json['dates'] as List)
            .map((e) => DateSlotModel(day: e['day'] as int, weekday: e['weekday'] as String))
            .toList(),
        timeSlots: (json['timeSlots'] as List)
            .map((e) => TimeSlotModel(
                time: e['time'] as String, available: e['available'] as bool))
            .toList(),
        address: json['address'] as String,
        pricing: PriceBreakdownModel(
          serviceFee: (json['pricing']['serviceFee'] as num).toDouble(),
          promoCode: json['pricing']['promoCode'] as String?,
          promoDiscount: (json['pricing']['promoDiscount'] as num).toDouble(),
          total: (json['pricing']['total'] as num).toDouble(),
        ),
      );
}

/// One row of `GET /bookings` — the My Bookings list.
class BookingListItemModel {
  const BookingListItemModel({
    required this.id,
    required this.vertical,
    required this.reference,
    required this.serviceName,
    required this.serviceIcon,
    required this.providerName,
    required this.status,
    required this.scheduledAt,
    required this.addressText,
    required this.total,
  });

  final String id;

  /// Which vertical owns this booking: `services`, `elkclean`, `elkrep`,
  /// `rentals`, `porter`, `rides` or `elkstay`. Cancelling routes on it —
  /// each vertical has its own endpoint.
  final String vertical;
  final String reference;
  final String serviceName;

  /// Emoji supplied by the backend (e.g. `🧹`), rendered as text.
  final String serviceIcon;
  final String providerName;

  /// Lower-cased backend status: `confirmed`, `completed` or `cancelled`.
  final String status;
  /// Null for a booking with no date yet — an immediate porter pickup.
  final DateTime? scheduledAt;
  final String addressText;
  final double total;

  bool get isUpcoming => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  /// "Today" / "Tomorrow" / "Sat 5 Jul" — relative to [now] so it stays testable.
  ///
  /// Weekday and month names come from `intl` in the active locale rather than
  /// a hardcoded English table, so a Malayalam user sees Malayalam dates.
  String dateLabel({DateTime? now}) {
    final l10n = L10n.current;
    final at = scheduledAt;
    if (at == null) return l10n.bookingNotScheduled;
    final today = _dateOnly(now ?? DateTime.now());
    final days = _dateOnly(at).difference(today).inDays;
    if (days == 0) return l10n.dateToday;
    if (days == 1) return l10n.dateTomorrow;
    if (days == -1) return l10n.dateYesterday;
    return DateFormat('EEE d MMM', l10n.localeName).format(at);
  }

  /// "11:00 AM", or an em dash when the booking carries no time.
  String get timeLabel {
    final at = scheduledAt;
    if (at == null) return '—';
    return DateFormat('h:mm a', L10n.current.localeName).format(at);
  }

  factory BookingListItemModel.fromJson(Map<String, dynamic> json) =>
      BookingListItemModel(
        id: json['id'] as String,
        vertical: json['vertical'] as String? ?? 'services',
        reference: json['reference'] as String,
        serviceName: json['serviceName'] as String,
        serviceIcon: json['serviceIcon'] as String? ?? '📋',
        providerName: json['providerName'] as String,
        status: (json['status'] as String).toLowerCase(),
        scheduledAt: json['scheduledAt'] == null
            ? null
            : DateTime.parse(json['scheduledAt'] as String).toLocal(),
        addressText: json['addressText'] as String,
        total: (json['total'] as num).toDouble(),
      );
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Result of confirming a booking — used on the Confirmation screen.
class BookingConfirmationModel {
  const BookingConfirmationModel({
    required this.bookingReference,
    required this.serviceName,
    required this.dateTimeLabel,
    required this.providerName,
    required this.amountPaid,
  });

  final String bookingReference;
  final String serviceName;
  final String dateTimeLabel;
  final String providerName;
  final double amountPaid;

  factory BookingConfirmationModel.fromJson(Map<String, dynamic> json) =>
      BookingConfirmationModel(
        bookingReference: json['bookingReference'] as String,
        serviceName: json['serviceName'] as String,
        dateTimeLabel: json['dateTimeLabel'] as String,
        providerName: json['providerName'] as String,
        amountPaid: (json['amountPaid'] as num).toDouble(),
      );
}
