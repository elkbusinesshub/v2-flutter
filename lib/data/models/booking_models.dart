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
}
