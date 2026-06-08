import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/device_model.dart';
import 'auth_service.dart';
import 'cloud_service.dart';

class DeviceService {
  static final ValueNotifier<List<DeviceModel>> devicesNotifier =
      ValueNotifier([]);

  static List<DeviceModel> _devices = [];

  // =====================================================
  // ✅ STORAGE KEY
  // =====================================================

  static Future<String> _getUserKey() async {
    final user = AuthService.currentUser;
    return "devices_${user?.email ?? 'guest'}";
  }

  // =====================================================
  // ✅ LOAD DEVICES
  // =====================================================

  static Future<void> loadDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _getUserKey();

      final data = prefs.getString(key);

      if (data != null) {
        final decoded = jsonDecode(data) as List;

        _devices = decoded
            .map((e) => DeviceModel.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      } else {
        _devices = [];
      }

      _refresh();
    } catch (e) {
      debugPrint("❌ Load error: $e");
      _devices = [];
      _refresh();
    }
  }

  // =====================================================
  // ✅ SAVE DEVICES (LOCAL)
  // =====================================================

  static Future<void> _saveDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _getUserKey();

      final encoded =
          jsonEncode(_devices.map((d) => d.toJson()).toList());

      await prefs.setString(key, encoded);
    } catch (e) {
      debugPrint("❌ Save error: $e");
    }
  }

  // =====================================================
  // ✅ REFRESH UI
  // =====================================================

  static void _refresh() {
    devicesNotifier.value = List.unmodifiable(_devices);
  }

  // =====================================================
  // ✅ READ
  // =====================================================

  static List<DeviceModel> getDevices() =>
      List.unmodifiable(_devices);

  static DeviceModel? getDeviceById(String id) {
    try {
      return _devices.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<DeviceModel> getDevicesForSale() {
    return _devices.where((d) => d.forSale).toList();
  }

  static List<DeviceModel> getUserDevices() {
    final user = AuthService.currentUser?.email;

    return _devices
        .where((d) => d.currentOwner == user)
        .toList();
  }

  // =====================================================
  // ✅ ADD DEVICE (FULL FIX ✅)
  // =====================================================

  static Future<void> addDevice(DeviceModel device) async {
    try {
      final normalizedImei = device.imei.trim();

      // ✅ BLOCK DUPLICATES (REAL FIX 🔥)
      final exists = _devices.any(
        (d) => d.imei.trim() == normalizedImei,
      );

      if (exists) {
        throw Exception("This IMEI already exists");
      }

      final user = AuthService.currentUser?.email;

      final newDevice = device.copyWith(
        imei: normalizedImei,
        currentOwner:
            device.currentOwner == "unknown"
                ? user
                : device.currentOwner,
        trustScore: device.calculateTrustScore(),
      );

      // ✅ ADD LOCALLY FIRST
      _devices.add(newDevice);

      await _saveDevices();
      _refresh();

      // ✅ THEN CLOUD (safe order)
      try {
        await CloudService.saveDevice(
          newDevice.id,
          newDevice.toJson(),
        );
      } catch (e) {
        debugPrint("⚠️ Cloud sync failed: $e");
      }

    } catch (e) {
      // ✅ VERY IMPORTANT: rethrow so UI can catch
      throw Exception(e.toString());
    }
  }

  // =====================================================
  // ✅ UPDATE
  // =====================================================

  static Future<void> updateDevice(DeviceModel device) async {
    try {
      final index =
          _devices.indexWhere((d) => d.id == device.id);

      if (index == -1) return;

      final updated = device.copyWith(
        trustScore: device.calculateTrustScore(),
      );

      _devices[index] = updated;

      await _saveDevices();
      _refresh();

      try {
        await CloudService.saveDevice(
          updated.id,
          updated.toJson(),
        );
      } catch (e) {
        debugPrint("⚠️ Cloud update failed: $e");
      }

    } catch (e) {
      debugPrint("❌ Update error: $e");
    }
  }

  // =====================================================
  // ✅ DELETE
  // =====================================================

  static Future<void> deleteDeviceById(String id) async {
    try {
      _devices.removeWhere((d) => d.id == id);

      await _saveDevices();
      _refresh();

      try {
        await CloudService.deleteDevice(id);
      } catch (e) {
        debugPrint("⚠️ Cloud delete failed: $e");
      }

    } catch (e) {
      debugPrint("❌ Delete error: $e");
    }
  }

  // =====================================================
  // ✅ TRUST ACTIONS
  // =====================================================

  static Future<void> reportDevice(String id) async {
    final device = getDeviceById(id);
    if (device == null) return;

    final updated = device.copyWith(
      reportCount: device.reportCount + 1,
      trustScore: device.calculateTrustScore(),
    );

    await updateDevice(updated);
  }

  static Future<void> verifyDevice(String id) async {
    final device = getDeviceById(id);
    if (device == null) return;

    final updated = device.copyWith(
      isVerified: true,
      trustScore: device.calculateTrustScore(),
    );

    await updateDevice(updated);
  }

  static Future<void> transferDevice(
    String id,
    String newOwner,
  ) async {
    final device = getDeviceById(id);
    if (device == null || newOwner.isEmpty) return;

    final updated = device.copyWith(
      currentOwner: newOwner,
      ownershipHistory: [
        ...device.ownershipHistory,
        device.currentOwner,
      ],
      ownershipYears: device.ownershipYears + 1,
      trustScore: device.calculateTrustScore(),
    );

    await updateDevice(updated);
  }

  // =====================================================
  // ✅ CLEAR MEMORY
  // =====================================================

  static void clearMemory() {
    _devices.clear();
    _refresh();
  }
}
