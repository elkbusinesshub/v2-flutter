class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarInitials,
    required this.bookingsCount,
    required this.rewardPoints,
    required this.rating,
  });

  final String id;
  final String name;
  final String phone;
  final String avatarInitials;
  final int bookingsCount;
  final int rewardPoints;
  final double rating;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        avatarInitials: json['avatarInitials'] as String,
        bookingsCount: json['bookingsCount'] as int,
        rewardPoints: json['rewardPoints'] as int,
        rating: (json['rating'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'avatarInitials': avatarInitials,
        'bookingsCount': bookingsCount,
        'rewardPoints': rewardPoints,
        'rating': rating,
      };
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.colorHex,
    this.isDestructive = false,
  });

  final String icon;
  final String label;
  final int colorHex;
  final bool isDestructive;
}
