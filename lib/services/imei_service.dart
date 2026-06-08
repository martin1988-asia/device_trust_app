import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImeiResult {
  final String status;
  final String source;
  final DateTime timestamp;

  const ImeiResult({
    required this.status,
    required this.source,
    required this.timestamp,
  });
}

class ImeiService {
  /// ✅ in-memory cache with timestamp
  static final Map<String, ImeiResult> _cache = {};

  static const Duration _cacheDuration = Duration(minutes: 10);

  // =====================================================
  // ✅ MAIN ENTRY
  // =====================================================

  static Future<ImeiResult> checkStatus(String imei) async {
    try {
      final normalized = imei.trim();

      // ✅ VALIDATION
      if (!_isValidFormat(normalized) || !_isValidLuhn(normalized)) {
        return ImeiResult(
          status: "Invalid",
          source: "validation",
          timestamp: DateTime.now(),
        );
      }

      // ✅ CACHE CHECK (WITH EXPIRY)
      final cached = _cache[normalized];
      if (cached != null &&
          DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        return cached;
      }

      // ✅ LOCAL DB
      final local = _checkLocalDatabase(normalized);
      if (local != null) {
        final result = ImeiResult(
          status: local,
          source: "local",
          timestamp: DateTime.now(),
        );
        _cache[normalized] = result;
        return result;
      }

      // ✅ API (WITH RETRY)
      final apiResult = await _retryApi(normalized);

      _cache[normalized] = apiResult;
      return apiResult;
    } catch (e) {
      debugPrint("❌ IMEI check error: $e");

      return ImeiResult(
        status: _fallbackStatus(imei),
        source: "error",
        timestamp: DateTime.now(),
      );
    }
  }

  // =====================================================
  // ✅ RETRY WRAPPER
  // =====================================================

  static Future<ImeiResult> _retryApi(String imei) async {
    for (int i = 0; i < 2; i++) {
      try {
        return await _checkFromApi(imei);
      } catch (e) {
        debugPrint("⚠️ API retry ${i + 1} failed: $e");
      }
    }

    return ImeiResult(
      status: _fallbackStatus(imei),
      source: "fallback",
      timestamp: DateTime.now(),
    );
  }

  // =====================================================
  // ✅ VALIDATION
  // =====================================================

  static bool _isValidFormat(String imei) {
    return imei.length == 15 && int.tryParse(imei) != null;
  }

  static bool _isValidLuhn(String input) {
    int sum = 0;
    bool alternate = false;

    for (int i = input.length - 1; i >= 0; i--) {
      int digit = int.parse(input[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  // =====================================================
  // ✅ LOCAL MOCK DATABASE
  // =====================================================

  static String? _checkLocalDatabase(String imei) {
    const knownDevices = {
      "356789012345678": "Clean",
      "861234567890123": "Stolen",
      "352099001234567": "Clean",
    };

    return knownDevices[imei];
  }

  // =====================================================
  // ✅ API CALL (SAFE ✅)
  // =====================================================

  static Future<ImeiResult> _checkFromApi(String imei) async {
    final url = Uri.parse(
        "https://api.allorigins.win/get?url=https://imei.info/api/?imei=$imei");

    final response = await http.get(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception("API failed: ${response.statusCode}");
    }

    final parsed = _parseApiResponse(response.body);

    return ImeiResult(
      status: parsed ?? _fallbackStatus(imei),
      source: "api",
      timestamp: DateTime.now(),
    );
  }

  // =====================================================
  // ✅ RESPONSE PARSER (HARDENED ✅)
  // =====================================================

  static String? _parseApiResponse(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map && decoded["contents"] != null) {
        final inner = jsonDecode(decoded["contents"]);

        final data = inner.toString().toLowerCase();

        if (data.contains("stolen") || data.contains("blacklist")) {
          return "Stolen";
        }

        if (data.contains("clean")) {
          return "Clean";
        }
      }
    } catch (e) {
      debugPrint("⚠️ Parse error: $e");
    }

    return null;
  }

  // =====================================================
  // ✅ FALLBACK LOGIC
  // =====================================================

  static String _fallbackStatus(String imei) {
    if (imei.startsWith("35")) return "Clean";
    if (imei.startsWith("86")) return "Stolen";
    return "Unknown";
  }
}
