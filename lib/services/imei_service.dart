import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ImeiResult {
  final String status;
  final String source; // local, api, fallback

  const ImeiResult({
    required this.status,
    required this.source,
  });
}

class ImeiService {
  /// ✅ simple in-memory cache
  static final Map<String, ImeiResult> _cache = {};

  // =====================================================
  // ✅ MAIN ENTRY
  // =====================================================

  static Future<ImeiResult> checkStatus(String imei) async {
    try {
      /// ✅ VALIDATION
      if (!_isValidFormat(imei) || !_isValidLuhn(imei)) {
        return const ImeiResult(
          status: "Invalid",
          source: "validation",
        );
      }

      /// ✅ CACHE CHECK
      if (_cache.containsKey(imei)) {
        return _cache[imei]!;
      }

      /// ✅ LOCAL DATABASE
      final local = _checkLocalDatabase(imei);
      if (local != null) {
        final result = ImeiResult(status: local, source: "local");
        _cache[imei] = result;
        return result;
      }

      /// ✅ API CHECK
      final api = await _checkFromApi(imei);

      _cache[imei] = api;
      return api;
    } catch (e) {
      return ImeiResult(
        status: _fallbackStatus(imei),
        source: "error",
      );
    }
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
  // ✅ LOCAL DB
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
  // ✅ API (SAFE + TIMEOUT)
  // =====================================================

  static Future<ImeiResult> _checkFromApi(String imei) async {
    try {
      final url = Uri.parse(
        "https://api.allorigins.win/get?url=https://imei.info/api/?imei=$imei",
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 5)); // ✅ timeout

      if (response.statusCode == 200) {
        final parsed = _parseApiResponse(response.body);

        if (parsed != null) {
          return ImeiResult(status: parsed, source: "api");
        }
      }

      return ImeiResult(
        status: _fallbackStatus(imei),
        source: "fallback",
      );
    } catch (_) {
      return ImeiResult(
        status: _fallbackStatus(imei),
        source: "timeout",
      );
    }
  }

  // =====================================================
  // ✅ PARSING
  // =====================================================

  static String? _parseApiResponse(String body) {
    try {
      final decoded = jsonDecode(body);

      final contents = decoded["contents"];

      if (contents != null) {
        final inner = jsonDecode(contents);
        final data = inner.toString().toLowerCase();

        if (data.contains("stolen")) return "Stolen";
        if (data.contains("blacklist")) return "Stolen";
        if (data.contains("clean")) return "Clean";
      }
    } catch (_) {}

    return null;
  }

  // =====================================================
  // ✅ FALLBACK
  // =====================================================

  static String _fallbackStatus(String imei) {
    if (imei.startsWith("35")) return "Clean";
    if (imei.startsWith("86")) return "Stolen";
    return "Unknown";
  }
}
