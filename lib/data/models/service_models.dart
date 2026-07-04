/// Top-level service category shown on the Home grid (Taxi, Cleaning, etc.)
class ServiceCategoryModel {
  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
  });

  final String id;
  final String name;
  final String icon;
  final int colorHex;

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) =>
      ServiceCategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        colorHex: json['colorHex'] as int,
      );
}

/// A sub-service shown inside a category on the Services catalogue screen.
class ServiceSubItemModel {
  const ServiceSubItemModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final String icon;

  factory ServiceSubItemModel.fromJson(Map<String, dynamic> json) =>
      ServiceSubItemModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
      );
}

/// A group of sub-services under a category heading (e.g. "Cleaning").
class ServiceGroupModel {
  const ServiceGroupModel({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final String icon;
  final List<ServiceSubItemModel> items;

  factory ServiceGroupModel.fromJson(Map<String, dynamic> json) =>
      ServiceGroupModel(
        title: json['title'] as String,
        icon: json['icon'] as String,
        items: (json['items'] as List)
            .map((e) => ServiceSubItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Full detail payload for the Service Detail screen.
class ServiceDetailModel {
  const ServiceDetailModel({
    required this.id,
    required this.title,
    required this.badge,
    required this.providerName,
    required this.providerInitials,
    required this.providerExperience,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    required this.teamSize,
    required this.category,
    required this.bookings,
    required this.included,
    required this.description,
    required this.price,
    required this.priceUnit,
  });

  final String id;
  final String title;
  final String badge;
  final String providerName;
  final String providerInitials;
  final String providerExperience;
  final double rating;
  final int reviewCount;
  final String duration;
  final String teamSize;
  final String category;
  final String bookings;
  final List<String> included;
  final String description;
  final double price;
  final String priceUnit;

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) =>
      ServiceDetailModel(
        id: json['id'] as String,
        title: json['title'] as String,
        badge: json['badge'] as String,
        providerName: json['providerName'] as String,
        providerInitials: json['providerInitials'] as String,
        providerExperience: json['providerExperience'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        duration: json['duration'] as String,
        teamSize: json['teamSize'] as String,
        category: json['category'] as String,
        bookings: json['bookings'] as String,
        included: List<String>.from(json['included'] as List),
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        priceUnit: json['priceUnit'] as String,
      );
}
