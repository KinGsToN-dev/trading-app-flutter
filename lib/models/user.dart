class User {
  final int id;
  final String email;
  final String username;
  final String telegramChatId;
  final String timezone;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.telegramChatId,
    required this.timezone,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'] ?? '',
        username: json['username'] ?? '',
        telegramChatId: json['telegram_chat_id'] ?? '',
        timezone: json['timezone'] ?? 'UTC',
      );
}