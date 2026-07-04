class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isOutgoing,
    this.senderInitials,
  });

  final String id;
  final String text;
  final String time;
  final bool isOutgoing;
  final String? senderInitials;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        text: json['text'] as String,
        time: json['time'] as String,
        isOutgoing: json['isOutgoing'] as bool,
        senderInitials: json['senderInitials'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'time': time,
        'isOutgoing': isOutgoing,
        'senderInitials': senderInitials,
      };
}

class ChatThreadModel {
  const ChatThreadModel({
    required this.contactName,
    required this.contactInitials,
    required this.contactStatus,
    required this.dateLabel,
    required this.messages,
  });

  final String contactName;
  final String contactInitials;
  final String contactStatus;
  final String dateLabel;
  final List<ChatMessageModel> messages;

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) =>
      ChatThreadModel(
        contactName: json['contactName'] as String,
        contactInitials: json['contactInitials'] as String,
        contactStatus: json['contactStatus'] as String,
        dateLabel: json['dateLabel'] as String,
        messages: (json['messages'] as List)
            .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
