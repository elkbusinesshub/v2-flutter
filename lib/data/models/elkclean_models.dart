import 'package:flutter/material.dart';

/// Models for the ELK Clean vertical (backend `/elkclean/*`).
///
/// Icons are client-side: the backend sends `iconKey` (the SVG asset
/// basename, e.g. `ic_home_clean`); the category [icon] used on detail
/// screens is derived from the slug.

class CleanCategoryModel {
  const CleanCategoryModel({
    required this.slug,
    required this.code,
    required this.label,
    required this.blurb,
    required this.iconKey,
    this.badge,
    this.star = false,
    this.serviceCount = 0,
  });

  final String slug;
  final String code;
  final String label;
  final String blurb;
  final String iconKey;
  final String? badge;
  final bool star;
  final int serviceCount;

  String get svgAsset => 'assets/icons/$iconKey.svg';

  static const _iconsBySlug = <String, IconData>{
    'cln': Icons.auto_awesome,
    'deep': Icons.cleaning_services,
    'tnk': Icons.water_drop,
    'sof': Icons.chair,
    'crp': Icons.layers,
    'kit': Icons.restaurant,
    'bth': Icons.bathtub,
    'lndr': Icons.local_laundry_service,
  };

  IconData get icon => _iconsBySlug[slug] ?? Icons.cleaning_services;

  factory CleanCategoryModel.fromJson(Map<String, dynamic> json) =>
      CleanCategoryModel(
        slug: json['id'] as String,
        code: json['code'] as String,
        label: json['label'] as String,
        blurb: json['blurb'] as String,
        iconKey: json['iconKey'] as String,
        badge: json['badge'] as String?,
        star: (json['star'] as bool?) ?? false,
        serviceCount: (json['serviceCount'] as int?) ?? 0,
      );
}

class CleanServiceModel {
  const CleanServiceModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.tag,
    this.checklist = const [],
    this.steps,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final int price;
  final String duration;
  final String? tag;
  final List<String> checklist;
  final List<String>? steps;

  factory CleanServiceModel.fromJson(Map<String, dynamic> json) =>
      CleanServiceModel(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: json['price'] as int,
        duration: json['duration'] as String,
        tag: json['tag'] as String?,
        checklist: (json['checklist'] as List?)?.cast<String>() ?? const [],
        steps: (json['steps'] as List?)?.cast<String>(),
      );
}

class CleanOfferModel {
  const CleanOfferModel({
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

  factory CleanOfferModel.fromJson(Map<String, dynamic> json) => CleanOfferModel(
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

class CleanHomeFeedModel {
  const CleanHomeFeedModel({
    required this.userName,
    required this.location,
    required this.categories,
    required this.offers,
  });

  final String userName;
  final String location;
  final List<CleanCategoryModel> categories;
  final List<CleanOfferModel> offers;

  factory CleanHomeFeedModel.fromJson(Map<String, dynamic> json) =>
      CleanHomeFeedModel(
        userName: json['userName'] as String,
        location: json['location'] as String,
        categories: (json['categories'] as List)
            .map((e) => CleanCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        offers: (json['offers'] as List)
            .map((e) => CleanOfferModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CleanDateOptionModel {
  const CleanDateOptionModel({
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

  factory CleanDateOptionModel.fromJson(Map<String, dynamic> json) =>
      CleanDateOptionModel(
        date: json['date'] as String,
        day: json['day'] as int,
        weekday: json['weekday'] as String,
        slots: ((json['slots'] as List?) ?? const []).cast<String>(),
      );
}

class CleanAddressModel {
  const CleanAddressModel({
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

  factory CleanAddressModel.fromJson(Map<String, dynamic> json) =>
      CleanAddressModel(
        id: json['id'] as String,
        label: json['label'] as String,
        line: json['line'] as String,
        isDefault: (json['isDefault'] as bool?) ?? false,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

class CleanBookingOptionsModel {
  const CleanBookingOptionsModel({
    required this.dates,
    required this.timeSlots,
    required this.supplyFee,
    required this.addresses,
  });

  final List<CleanDateOptionModel> dates;
  final List<String> timeSlots;
  final int supplyFee;
  final List<CleanAddressModel> addresses;

  factory CleanBookingOptionsModel.fromJson(Map<String, dynamic> json) =>
      CleanBookingOptionsModel(
        dates: (json['dates'] as List)
            .map((e) => CleanDateOptionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        timeSlots: (json['timeSlots'] as List).cast<String>(),
        supplyFee: json['supplyFee'] as int,
        addresses: (json['addresses'] as List)
            .map((e) => CleanAddressModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// One cart line — client-side state, priced from the server catalog entry.
class CleanCartLine {
  const CleanCartLine({required this.service, required this.quantity});

  final CleanServiceModel service;
  final int quantity;

  int get lineTotal => service.price * quantity;

  CleanCartLine copyWith({int? quantity}) =>
      CleanCartLine(service: service, quantity: quantity ?? this.quantity);
}

/// A created (or listed) clean booking.
class CleanBookingModel {
  const CleanBookingModel({
    required this.id,
    required this.code,
    required this.status,
    required this.scheduledDate,
    required this.timeSlot,
    required this.addressLabel,
    required this.addressLine,
    required this.subtotal,
    required this.supplyFee,
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
  final int supplyFee;
  final String? promoCode;
  final int discountAmount;
  final int totalAmount;
  final String paymentMethod;

  factory CleanBookingModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>;
    final breakdown = json['breakdown'] as Map<String, dynamic>;
    return CleanBookingModel(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      scheduledDate: json['scheduledDate'] as String,
      timeSlot: json['timeSlot'] as String,
      addressLabel: address['label'] as String,
      addressLine: address['line'] as String,
      subtotal: breakdown['subtotal'] as int,
      supplyFee: breakdown['supplyFee'] as int,
      promoCode: breakdown['promoCode'] as String?,
      discountAmount: breakdown['discountAmount'] as int,
      totalAmount: breakdown['totalAmount'] as int,
      paymentMethod: json['paymentMethod'] as String,
    );
  }
}
