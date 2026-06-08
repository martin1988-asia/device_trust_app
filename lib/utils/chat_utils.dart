class ChatUtils {
  // =====================================================
  // ✅ GENERATE CHAT ID (SAFE + SCALABLE)
  // =====================================================

  static String generateChatId(
    String deviceId,
    String user1,
    String user2,
  ) {
    final users = [_normalize(user1), _normalize(user2)]
      ..sort();

    return "$deviceId-${users.join('-')}";
  }

  // =====================================================
  // ✅ GROUP CHAT SUPPORT (FUTURE READY)
  // =====================================================

  static String generateGroupChatId(
    String deviceId,
    List<String> userIds,
  ) {
    final normalized =
        userIds.map((u) => _normalize(u)).toList()..sort();

    return "$deviceId-${normalized.join('-')}";
  }

  // =====================================================
  // ✅ PARSE CHAT ID
  // =====================================================

  static Map<String, dynamic> parseChatId(String chatId) {
    final parts = chatId.split('-');

    if (parts.length < 3) {
      return {
        "deviceId": "",
        "users": [],
      };
    }

    return {
      "deviceId": parts.first,
      "users": parts.sublist(1),
    };
  }

  // =====================================================
  // ✅ CHECK USER IN CHAT
  // =====================================================

  static bool isUserInChat(
    String chatId,
    String userId,
  ) {
    final data = parseChatId(chatId);

    final users = List<String>.from(data["users"]);

    return users.contains(_normalize(userId));
  }

  // =====================================================
  // ✅ NORMALIZE STRING
  // =====================================================

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
