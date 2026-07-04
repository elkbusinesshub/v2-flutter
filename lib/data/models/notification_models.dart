class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.icon,
    required this.colorHex,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  final String id;
  final String icon;
  final int colorHex;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  NotificationModel copyWith({bool? isUnread}) => NotificationModel(
        id: id,
        icon: icon,
        colorHex: colorHex,
        title: title,
        message: message,
        time: time,
        isUnread: isUnread ?? this.isUnread,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        icon: json['icon'] as String,
        colorHex: json['colorHex'] as int,
        title: json['title'] as String,
        message: json['message'] as String,
        time: json['time'] as String,
        isUnread: json['isUnread'] as bool,
      );
}
