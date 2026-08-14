import 'package:flutter/material.dart';

/// Models for the ELK Repair vertical (backend `/elkrep/*`).
///
/// Mirrors the ElkClean shapes with two differences: the flat fee is a
/// **visit & inspection fee**, and services carry a static "what's
/// included" list instead of a per-service checklist.

class RepairCategoryModel {
  const RepairCategoryModel({
    required this.slug,
    required this.code,
    required this.label,
    required this.blurb,
    required this.iconKey,
    this.serviceCount = 0,
  });

  final String slug;
  final String code;
  final String label;
  final String blurb;
  final String iconKey;
  final int serviceCount;

  String get svgAsset => 'assets/icons/$iconKey.svg';

  static const _iconsBySlug = <String, IconData>{
    'ac': Icons.ac_unit,
    'plm': Icons.water_drop,
    'elc': Icons.bolt,
    'cpt': Icons.handyman,
    'pnt': Icons.format_paint,
    'gen': Icons.build,
  };

  IconData get icon => _iconsBySlug[slug] ?? Icons.build;

  factory RepairCategoryModel.fromJson(Map<String, dynamic> json) =>
      RepairCategoryModel(
        slug: json['id'] as String,
        code: json['code'] as String,
        label: json['label'] as String,
        blurb: json['blurb'] as String,
        iconKey: json['iconKey'] as String,
        serviceCount: (json['serviceCount'] as int?) ?? 0,
      );
}

class RepairServiceModel {
  const RepairServiceModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.tag,
    this.included = const [],
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final int price;
  final String duration;
  final String? tag;

  /// Static "what's included" copy, identical for every repair job.
  final List<String> included;

  factory RepairServiceModel.fromJson(Map<String, dynamic> json) =>
      RepairServiceModel(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: json['price'] as int,
        duration: json['duration'] as String,
        tag: json['tag'] as String?,
        included: (json['included'] as List?)?.cast<String>() ?? const [],
      );
}

class RepairOfferModel {
  const RepairOfferModel({
    required this.id,
    required this.title,
    required this.discount,
    required this.code,
    required this.time,
    required this.unit,
    required this.category,
    required this.iconKey,
  });

  final String id;
  final String title;
  final String discount;
  final String code;
  final String time;
  final String unit;
  final String category;
  final String iconKey;

  String get svgAsset => 'assets/icons/$iconKey.svg';

  factory RepairOfferModel.fromJson(Map<String, dynamic> json) =>
      RepairOfferModel(
        id: json['id'] as String,
        title: json['title'] as String,
        discount: json['discount'] as String,
        code: json['code'] as String,
        time: json['time'] as String,
        unit: json['unit'] as String,
        category: json['category'] as String,
        iconKey: json['iconKey'] as String,
      );
}

class RepairHomeFeedModel {
  const RepairHomeFeedModel({
    required this.userName,
    required this.location,
    required this.categories,
    required this.offers,
  });

  final String userName;
  final String location;
  final List<RepairCategoryModel> categories;
  final List<RepairOfferModel> offers;

  factory RepairHomeFeedModel.fromJson(Map<String, dynamic> json) =>
      RepairHomeFeedModel(
        userName: json['userName'] as String,
        location: json['location'] as String,
        categories: (json['categories'] as List)
            .map((e) => RepairCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        offers: (json['offers'] as List)
            .map((e) => RepairOfferModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RepairDateOptionModel {
  const RepairDateOptionModel({
    required this.date,
    required this.day,
    required this.weekday,
    this.slots = const [],
  });

  /// `YYYY-MM-DD`, sent back verbatim when booking.
  final String date;
  final int day;
  final String weekday;

  /// Arrival windows still bookable on this date. Today's list shrinks as the
  /// day passes; the backend rejects anything not in here.
  final List<String> slots;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  String get monthLabel => _months[DateTime.parse(date).month - 1];

  factory RepairDateOptionModel.fromJson(Map<String, dynamic> json) =>
      RepairDateOptionModel(
        date: json['date'] as String,
        day: json['day'] as int,
        weekday: json['weekday'] as String,
        slots: ((json['slots'] as List?) ?? const []).cast<String>(),
      );
}

class RepairAddressModel {
  const RepairAddressModel({
    required this.id,
    required this.label,
    required this.line,
    this.isDefault = false,
    this.lat,
    this.lng,
  });

  final String id;
  final String label;
  final String line;
  final bool isDefault;

  /// Null on rows saved before the backend started returning coordinates.
  final double? lat;
  final double? lng;

  factory RepairAddressModel.fromJson(Map<String, dynamic> json) =>
      RepairAddressModel(
        id: json['id'] as String,
        label: json['label'] as String,
        line: json['line'] as String,
        isDefault: (json['isDefault'] as bool?) ?? false,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

class RepairBookingOptionsModel {
  const RepairBookingOptionsModel({
    required this.dates,
    required this.timeSlots,
    required this.visitFee,
    required this.addresses,
  });

  final List<RepairDateOptionModel> dates;
  final List<String> timeSlots;
  final int visitFee;
  final List<RepairAddressModel> addresses;

  factory RepairBookingOptionsModel.fromJson(Map<String, dynamic> json) =>
      RepairBookingOptionsModel(
        dates: (json['dates'] as List)
            .map((e) => RepairDateOptionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        timeSlots: (json['timeSlots'] as List).cast<String>(),
        visitFee: json['visitFee'] as int,
        addresses: (json['addresses'] as List)
            .map((e) => RepairAddressModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// One cart line — client-side state, priced from the server catalog entry.
class RepairCartLine {
  const RepairCartLine({required this.service, required this.quantity});

  final RepairServiceModel service;
  final int quantity;

  int get lineTotal => service.price * quantity;

  RepairCartLine copyWith({int? quantity}) =>
      RepairCartLine(service: service, quantity: quantity ?? this.quantity);
}

class RepairBookingModel {
  const RepairBookingModel({
    required this.id,
    required this.code,
    required this.status,
    required this.scheduledDate,
    required this.timeSlot,
    required this.addressLabel,
    required this.addressLine,
    required this.subtotal,
    required this.visitFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    this.promoCode,
  });

  final String id;
  final String code;
  final String status;

  /// `YYYY-MM-DD`
  final String scheduledDate;
  final String timeSlot;
  final String addressLabel;
  final String addressLine;
  final int subtotal;
  final int visitFee;
  final String? promoCode;
  final int discountAmount;
  final int totalAmount;
  final String paymentMethod;

  factory RepairBookingModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>;
    final breakdown = json['breakdown'] as Map<String, dynamic>;
    return RepairBookingModel(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      scheduledDate: json['scheduledDate'] as String,
      timeSlot: json['timeSlot'] as String,
      addressLabel: address['label'] as String,
      addressLine: address['line'] as String,
      subtotal: breakdown['subtotal'] as int,
      visitFee: breakdown['visitFee'] as int,
      promoCode: breakdown['promoCode'] as String?,
      discountAmount: breakdown['discountAmount'] as int,
      totalAmount: breakdown['totalAmount'] as int,
      paymentMethod: json['paymentMethod'] as String,
    );
  }
}
