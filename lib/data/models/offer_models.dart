class OfferModel {
  const OfferModel({
    required this.id,
    required this.tagLabel,
    required this.title,
    required this.description,
    required this.code,
    required this.expiry,
    required this.discountLabel,
    required this.discountSubLabel,
    required this.gradientStartHex,
    required this.gradientEndHex,
  });

  final String id;
  final String tagLabel;
  final String title;
  final String description;
  final String code;
  final String expiry;
  final String discountLabel;
  final String discountSubLabel;
  final int gradientStartHex;
  final int gradientEndHex;

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
        id: json['id'] as String,
        tagLabel: json['tagLabel'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        code: json['code'] as String,
        expiry: json['expiry'] as String,
        discountLabel: json['discountLabel'] as String,
        discountSubLabel: json['discountSubLabel'] as String,
        gradientStartHex: json['gradientStartHex'] as int,
        gradientEndHex: json['gradientEndHex'] as int,
      );
}

class OffersPageModel {
  const OffersPageModel({
    required this.rewardPoints,
    required this.rewardDiscountLabel,
    required this.offers,
  });

  final int rewardPoints;
  final String rewardDiscountLabel;
  final List<OfferModel> offers;
}
