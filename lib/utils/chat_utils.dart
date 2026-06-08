import 'package:flutter/foundation.dart';

class ChatUtils {
  static const String _separator = '|';

  // =====================================================
  // ✅ GENERATE CHAT ID (SAFE ✅)
  // =====================================================

  static String generateChatId(
    String deviceId,
    String user1,
    String user2,
  ) {
    final d = _normalize(deviceId);

    if (d.isEmpty) {
      throw Exception("Device ID cannot be empty");
    }

    final users = [_normalize(user1), _normalize(user2)]
      ..removeWhere((u) => u.isEmpty)
      ..sort();

    if (users.length < 2) {
      throw Exception("Two valid users required");
    }

    return "$d$_separator${users.join(_separator)}";
  }

  // =====================================================
  // ✅ GROUP CHAT (SAFE + DEDUPLICATED ✅)
  // =====================================================

  static String generateGroupChatId(
    String deviceId,
    List<String> userIds,
  ) {
    final d = _normalize(deviceId);

    if (d.isEmpty) {
      throw Exception("Device ID cannot be empty");
    }

    final users = userIds
        .map(_normalize)
        .where((u) => u.isNotEmpty)
        .toSet() // ✅ remove duplicates
        .toList()
      ..sort();

    if (users.length < 2) {
      throw Exception("At least two users required");
    }

    return "$d$_separator${users.join(_separator)}";
  }

  // =====================================================
  // ✅ PARSE CHAT ID (DEFENSIVE ✅)
  // =====================================================

  static Map<String, dynamic> parseChatId(String chatId) {
    if (chatId.trim().isEmpty) {
      debugPrint("⚠️ parseChatId: empty chatId");
      return {"deviceId": "", "users": <String>[]};
    }

    final parts = chatId.split(_separator);

    if (parts.length < 2) {
      debugPrint("⚠️ parseChatId: invalid format");
      return {"deviceId": "", "users": <String>[]};
    }

    final deviceId = parts.first;
    final users = parts.sublist(1);

    return {
      "deviceId": deviceId,
      "users": users,
    };
  }

  // =====================================================
  // ✅ CHECK USER IN CHAT
  // =====================================================

  static bool isUserInChat(String chatId, String userId) {
    final parsed = parseChatId(chatId);

    final users = (parsed["users"] as List).cast<String>();

    return users.contains(_normalize(userId));
  }

  // =====================================================
  // ✅ NORMALIZE (STRICT ✅)
  // =====================================================

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  // =====================================================
  // ✅ SAFE COMPARE CHAT IDS
  // =====================================================

  static bool areSameChat(String a, String b) {
    return _normalize(a) == _normalize(b);
  }

  // =====================================================
  // ✅ EXTRACT DEVICE ID
  // =====================================================

  static String getDeviceId(String chatId) {
    final parsed = parseChatId(chatId);
    return parsed["deviceId"] as String;
  }

  // =====================================================
  // ✅ EXTRACT USERS
  // =====================================================

  static List<String> getUsers(String chatId) {
    final parsed = parseChatId(chatId);
    return List<String>.from(parsed["users"]);
  }
}
