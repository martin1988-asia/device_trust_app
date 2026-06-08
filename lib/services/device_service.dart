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
  // ✅ LOAD DEVICES (SAFE ✅)
  // =====================================================

  static Future<void> loadDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _getUserKey();

      final data = prefs.getString(key);

      if (data != null) {
        try {
          final decoded = jsonDecode(data) as List;

          _devices = decoded
              .map((e) => DeviceModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } catch (e) {
          debugPrint("⚠️ Corrupted cache, resetting: $e");
          _devices = [];
        }
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
  // ✅ SAVE DEVICES (SAFE ✅)
  // =====================================================

  static Future<void> _saveDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _getUserKey();

      final encoded = jsonEncode(_devices.map((d) => d.toJson()).toList());

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
  // ✅ READ API (OPTIMIZED)
  // =====================================================

  static List<DeviceModel> getDevices() => List.unmodifiable(_devices);

  static DeviceModel? getDeviceById(String id) {
    for (final d in _devices) {
      if (d.id == id) return d;
    }
    return null;
  }

  static List<DeviceModel> getDevicesForSale() =>
      _devices.where((d) => d.forSale).toList(growable: false);

  static List<DeviceModel> getUserDevices() {
    final user = AuthService.currentUser?.email;
    return _devices
        .where((d) => d.currentOwner == user)
        .toList(growable: false);
  }

  // =====================================================
  // ✅ ADD DEVICE (ROBUST ✅)
  // =====================================================

  static Future<void> addDevice(DeviceModel device) async {
    try {
      final normalizedImei = device.imei.trim().toLowerCase();

      final exists = _devices.any(
        (d) => d.imei.trim().toLowerCase() == normalizedImei,
      );

      if (exists) {
        throw Exception("This IMEI already exists");
      }

      final user = AuthService.currentUser?.email;

      final newDevice = device.copyWith(
        imei: normalizedImei,
        currentOwner:
            device.currentOwner == "unknown" ? user : device.currentOwner,
        trustScore: device.calculateTrustScore(),
      );

      _devices.add(newDevice);

      await _saveDevices();
      _refresh();

      try {
        await CloudService.saveDevice(newDevice.id, newDevice.toJson());
      } catch (e) {
        debugPrint("⚠️ Cloud sync failed: $e");
      }
    } catch (e) {
      debugPrint("❌ Add device error: $e");
      rethrow;
    }
  }

  // =====================================================
  // ✅ UPDATE (SAFE ✅)
  // =====================================================

  static Future<void> updateDevice(DeviceModel device) async {
    final index = _devices.indexWhere((d) => d.id == device.id);

    if (index == -1) {
      debugPrint("⚠️ Device not found for update");
      return;
    }

    try {
      final updated = device.copyWith(
        trustScore: device.calculateTrustScore(),
      );

      _devices[index] = updated;

      await _saveDevices();
      _refresh();

      try {
        await CloudService.saveDevice(updated.id, updated.toJson());
      } catch (e) {
        debugPrint("⚠️ Cloud update failed: $e");
      }
    } catch (e) {
      debugPrint("❌ Update error: $e");
    }
  }

  // =====================================================
  // ✅ DELETE (SAFE ✅)
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

    await updateDevice(
      device.copyWith(
        reportCount: device.reportCount + 1,
      ),
    );
  }

  static Future<void> verifyDevice(String id) async {
    final device = getDeviceById(id);
    if (device == null) return;

    await updateDevice(
      device.copyWith(isVerified: true),
    );
  }

  static Future<void> transferDevice(String id, String newOwner) async {
    final device = getDeviceById(id);
    if (device == null || newOwner.isEmpty) return;

    await updateDevice(
      device.copyWith(
        currentOwner: newOwner,
        ownershipHistory: [...device.ownershipHistory, device.currentOwner],
        ownershipYears: device.ownershipYears + 1,
      ),
    );
  }

  // =====================================================
  // ✅ MEMORY CONTROL
  // =====================================================

  static void clearMemory() {
    _devices.clear();
    _refresh();
  }
}
