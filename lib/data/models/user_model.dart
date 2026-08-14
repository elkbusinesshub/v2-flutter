/// The signed-in user, backed by the backend's `ProfileDto`
/// (`GET /users/me` → `{ id, phone, email, name, language, roles }`).
///
/// [bookingsCount], [rewardPoints] and [rating] are not served by the
/// profile endpoint yet — they default to zero until the backend exposes
/// user stats.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.language = 'en',
    this.roles = const ['USER'],
    this.bookingsCount = 0,
    this.rewardPoints = 0,
    this.rating = 0,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String language;
  final List<String> roles;
  final int bookingsCount;
  final int rewardPoints;
  final double rating;

  /// Initials shown in the avatar circle, derived from [name].
  String get avatarInitials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return 'U';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        // name/phone are nullable server-side (first login creates a bare user).
        name: (json['name'] as String?) ?? 'ELK User',
        phone: (json['phone'] as String?) ?? '',
        email: json['email'] as String?,
        language: (json['language'] as String?) ?? 'en',
        roles: (json['roles'] as List?)?.cast<String>() ?? const ['USER'],
        bookingsCount: (json['bookingsCount'] as int?) ?? 0,
        rewardPoints: (json['rewardPoints'] as int?) ?? 0,
        rating: ((json['rating'] as num?) ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'language': language,
        'roles': roles,
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
