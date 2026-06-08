import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../models/circle_model.dart';
import '../../services/device_service.dart';
import '../../models/device_model.dart';
import '../../services/imei_service.dart';
import '../../services/auth_service.dart';
import '../../features/auth/login_page.dart';
import '../../models/user_model.dart';
import '../../services/circle_service.dart';
import '../../services/location_service.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  bool _isLoadingDevices = true;

  double? _lat;
  double? _lng;

  latlng.LatLng? _lastCameraPosition;

  StreamSubscription<Position>? _positionStream;

  List<UserModel> _circleUsers = [];

  bool _isLocateHover = false;
  bool _isStopHover = false;
  bool _mapReady = false;

  final MapController _mapController = MapController();

  final Map<String, latlng.LatLng> _previousPositions = {};

  final Map<String, List<latlng.LatLng>> _movementHistory = {};

  final Map<String, Future<ImeiResult>> _imeiFutures = {};

  Future<Circle?>? _circleFuture;
  Future<Map<String, String>>? _userNamesFuture;

  @override
  void initState() {
    super.initState();

    _getLocation();
    _loadDevices();

    _circleFuture = CircleService.getMyCircle();
  }

  // =====================================================
  // ✅ DEVICE LOADER (UPGRADED SAFE ✅)
  // =====================================================

  Future<void> _loadDevices() async {
    try {
      print("📦 Loading devices...");

      await DeviceService.loadDevices().timeout(const Duration(seconds: 5));

      print("✅ Devices loaded");
    } catch (e) {
      print("❌ Device load error: $e");
    }

    if (!mounted) return;

    setState(() {
      _isLoadingDevices = false;
    });
  }

  // =====================================================
  // ✅ LOCATION (IMPROVED ✅)
  // =====================================================

  Future<void> _getLocation() async {
    if (_positionStream != null) return;

    if (!await Geolocator.isLocationServiceEnabled()) return;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _lat = position.latitude;
      _lng = position.longitude;
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position pos) async {
      if (!mounted) return;

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });

      _animateCamera();

      await AuthService.updateLocation(pos.latitude, pos.longitude);
    });
  }

  void _animateCamera() {
    if (!_mapReady || _lat == null || _lng == null) return;

    final newPosition = latlng.LatLng(_lat!, _lng!);

    // ✅ prevent unnecessary movement (distance threshold)
    if (_lastCameraPosition != null) {
      final distance =
          (newPosition.latitude - _lastCameraPosition!.latitude).abs() +
              (newPosition.longitude - _lastCameraPosition!.longitude).abs();

      if (distance < 0.0005) {
        return; // ✅ skip small movements (prevents jitter)
      }
    }

    try {
      _mapController.move(newPosition, 13);
      _lastCameraPosition = newPosition; // ✅ remember last position
    } catch (_) {}
  }

  void _stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  // =====================================================
  // ✅ STATUS HELPER (UNCHANGED BUT CLEAN)
  // =====================================================

  String _getUserStatus(UserModel user) {
    if (user.lastSeen == null) return "offline";

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - user.lastSeen!;

    if (diff < 10000) return "online";
    if (diff < 60000) return "recent";

    final minutes = (diff / 60000).floor();
    return "last seen ${minutes}m ago";
  }

// =====================================================
// ✅ IMEI FUTURE CACHE (PERFORMANCE FIX ✅)
// =====================================================

  Future<ImeiResult> _getImeiFuture(String imei) {
    if (_imeiFutures.containsKey(imei)) {
      return _imeiFutures[imei]!;
    }

    final future = ImeiService.checkStatus(imei);
    _imeiFutures[imei] = future;

    return future;
  }

// =====================================================
// ✅ SAFE POSITION UPDATE (OUTSIDE BUILD ✅)
// =====================================================

  void _updateTrackingData(String id, latlng.LatLng newPosition) {
    _previousPositions[id] = newPosition;

    if (!_movementHistory.containsKey(id)) {
      _movementHistory[id] = [];
    }

    _movementHistory[id]!.add(newPosition);

    if (_movementHistory[id]!.length > 20) {
      _movementHistory[id]!.removeAt(0);
    }
  }

  // =====================================================
  // ✅ BUILD (FULL PREMIUM UI ✅)
  // =====================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDevices) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF020617), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✅ GLOW EFFECTS (DEPTH)
          Positioned(
            top: -120,
            left: -80,
            child: _GlowCircle(color: Colors.blue),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _GlowCircle(color: Colors.purple),
          ),

          // ✅ MAIN CONTENT
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),

                    // ✅ GLASS PANEL BACKGROUND
                    color: Colors.white.withValues(alpha: 0.04),

                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =====================================================
                      // ✅ PREMIUM HEADER
                      // =====================================================
                      Row(
                        children: [
                          // ✅ LEFT ICON (IMPROVED)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.devices,
                              color: Color(0xFF38BDF8),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ✅ TITLE BLOCK
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Device Trust",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "My Devices",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // ✅ ACTION BUTTONS (UPGRADED 🔥)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _headerAction(
                                  icon: Icons.storefront,
                                  tooltip: "Marketplace",
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/marketplace',
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                _headerAction(
                                  icon: Icons.refresh,
                                  tooltip: "Refresh",
                                  onTap: _loadDevices,
                                ),
                                const SizedBox(width: 8),
                                _headerAction(
                                  icon: Icons.group_add,
                                  tooltip: "Create Family",
                                  onTap: _createFamily,
                                ),
                                const SizedBox(width: 8),
                                _headerAction(
                                  icon: Icons.person_add,
                                  tooltip: "Join Family",
                                  onTap: _showJoinDialog,
                                ),
                                const SizedBox(width: 8),
                                _headerAction(
                                  icon: Icons.logout,
                                  tooltip: "Logout",
                                  onTap: _confirmLogout,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ✅ ACTION BUTTONS (MOBILE RESPONSIVE ✅)
                      // =====================================================
                      MediaQuery.of(context).size.width < 600
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: _actionButton(
                                    label: "Locate Me",
                                    icon: Icons.my_location,
                                    isHover: _isLocateHover,
                                    onEnter: () =>
                                        setState(() => _isLocateHover = true),
                                    onExit: () =>
                                        setState(() => _isLocateHover = false),
                                    onTap: _getLocation,
                                    gradient: const [
                                      Color(0xFF2563EB),
                                      Color(0xFF38BDF8),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: _outlinedActionButton(
                                    label: "Stop",
                                    icon: Icons.stop_circle,
                                    isHover: _isStopHover,
                                    onEnter: () =>
                                        setState(() => _isStopHover = true),
                                    onExit: () =>
                                        setState(() => _isStopHover = false),
                                    onTap: _stopTracking,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _actionButton(
                                    label: "Locate Me",
                                    icon: Icons.my_location,
                                    isHover: _isLocateHover,
                                    onEnter: () =>
                                        setState(() => _isLocateHover = true),
                                    onExit: () =>
                                        setState(() => _isLocateHover = false),
                                    onTap: _getLocation,
                                    gradient: const [
                                      Color(0xFF2563EB),
                                      Color(0xFF38BDF8),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _outlinedActionButton(
                                    label: "Stop",
                                    icon: Icons.stop_circle,
                                    isHover: _isStopHover,
                                    onEnter: () =>
                                        setState(() => _isStopHover = true),
                                    onExit: () =>
                                        setState(() => _isStopHover = false),
                                    onTap: _stopTracking,
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 12),

                      // =====================================================
                      // ✅ LOCATION TEXT (UPDATED ✅)
                      // =====================================================
                      Text(
                        "Live family tracking enabled",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =====================================================
                      // ✅ PREMIUM FAMILY MAP CARD (REAL-TIME ✅)
                      // =====================================================
                      SizedBox(
                        height: 220,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                FutureBuilder(
                                  future: _circleFuture,
                                  builder: (context, circleSnapshot) {
                                    if (!circleSnapshot.hasData ||
                                        circleSnapshot.data == null) {
                                      return const Center(
                                        child: Text(
                                          "No family circle found",
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                      );
                                    }

                                    final circle = circleSnapshot.data!;
                                    final members = circle.memberIds;

                                    return StreamBuilder(
                                      stream: LocationService.streamLocations(
                                        members,
                                      ),
                                      builder: (context, locationSnapshot) {
                                        if (!locationSnapshot.hasData) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final docs =
                                            locationSnapshot.data!.docs;

                                        if (docs.isEmpty) {
                                          return const Center(
                                            child: Text(
                                              "Waiting for live locations...",
                                              style: TextStyle(
                                                color: Colors.white54,
                                              ),
                                            ),
                                          );
                                        }

                                        return FutureBuilder<
                                            Map<String, String>>(
                                          future: _userNamesFuture ??=
                                              CircleService.getUserNames(
                                                  members),
                                          builder: (context, nameSnapshot) {
                                            if (!nameSnapshot.hasData) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }

                                            final nameMap = nameSnapshot.data!;

                                            final markers = docs
                                                .map((doc) {
                                                  final data = doc.data()
                                                      as Map<String, dynamic>;

                                                  final lat = data['lat'];
                                                  final lng = data['lng'];

                                                  if (lat == null ||
                                                      lng == null) return null;

                                                  final rawName =
                                                      nameMap[doc.id] ?? "User";

                                                  // ✅ CLEAN NAME (Smart Identity Formatting 🔥)
                                                  final displayName = (() {
                                                    if (rawName.contains("@")) {
                                                      final name = rawName
                                                          .split("@")
                                                          .first;

                                                      // ✅ Capitalize first letter (professional look)
                                                      return name.isNotEmpty
                                                          ? name[0]
                                                                  .toUpperCase() +
                                                              name.substring(1)
                                                          : "User";
                                                    }
                                                    return rawName;
                                                  })();

                                                  return Marker(
                                                    point:
                                                        latlng.LatLng(lat, lng),
                                                    width: 100,
                                                    height: 100,
                                                    child: _buildAnimatedMarker(
                                                      id: doc.id,
                                                      newPosition:
                                                          latlng.LatLng(
                                                        lat,
                                                        lng,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // ✅ NAME TAG (ULTRA PREMIUM — BETTER THAN LIFE360 🔥)
                                                          AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                              milliseconds: 400,
                                                            ),
                                                            curve: Curves
                                                                .easeOutCubic,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 10,
                                                              vertical: 4,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                10,
                                                              ),

                                                              // ✅ glass + depth effect
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Colors.black
                                                                      .withValues(
                                                                    alpha: 0.75,
                                                                  ),
                                                                  Colors.black
                                                                      .withValues(
                                                                    alpha: 0.55,
                                                                  ),
                                                                ],
                                                              ),

                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white
                                                                    .withValues(
                                                                  alpha: 0.12,
                                                                ),
                                                              ),

                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                                  blurRadius:
                                                                      12,
                                                                  offset:
                                                                      const Offset(
                                                                    0,
                                                                    4,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                // ✅ ONLINE PULSE DOT (LIVE FEEL 🔥)
                                                                Container(
                                                                  width: 6,
                                                                  height: 6,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:
                                                                        const Color(
                                                                      0xFF22C55E,
                                                                    ), // green dot
                                                                    shape: BoxShape
                                                                        .circle,

                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color:
                                                                            const Color(
                                                                          0xFF22C55E,
                                                                        ).withValues(
                                                                          alpha:
                                                                              0.8,
                                                                        ),
                                                                        blurRadius:
                                                                            8,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                                const SizedBox(
                                                                  width: 6,
                                                                ),

                                                                // ✅ NAME TEXT (CLEAN + STRONG)
                                                                ConstrainedBox(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                    maxWidth:
                                                                        70,
                                                                  ),
                                                                  child: Text(
                                                                    displayName,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      letterSpacing:
                                                                          0.3,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                            height: 6,
                                                          ),

                                                          // ✅ AVATAR MARKER (PREMIUM GLOW++)
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(6),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              gradient:
                                                                  const LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFF38BDF8),
                                                                  Color(
                                                                      0xFF6366F1),
                                                                ],
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .blueAccent
                                                                      .withValues(
                                                                          alpha:
                                                                              0.6),
                                                                  blurRadius:
                                                                      18,
                                                                  spreadRadius:
                                                                      2,
                                                                ),
                                                              ],
                                                            ),
                                                            child: const Icon(
                                                              Icons.person,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                })
                                                .whereType<Marker>()
                                                .toList();

                                            return GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onPanDown: (_) {},
                                              child: FlutterMap(
                                                mapController: _mapController,
                                                options: MapOptions(
                                                  initialCenter: markers
                                                          .isNotEmpty
                                                      ? markers.first.point
                                                      : latlng.LatLng(
                                                          _lat ?? 0, _lng ?? 0),
                                                  initialZoom: 13,
                                                  interactionOptions:
                                                      const InteractionOptions(
                                                    flags: InteractiveFlag.all,
                                                  ),
                                                  onMapReady: () {
                                                    _mapReady = true;
                                                  },
                                                ),
                                                children: [
                                                  // ✅ BASE MAP
                                                  TileLayer(
                                                    urlTemplate:
                                                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                                  ),

                                                  // ✅ 🔥 MOVEMENT TRAILS (PREMIUM ✅)
                                                  PolylineLayer(
                                                    polylines: _movementHistory
                                                        .entries
                                                        .map((entry) {
                                                      final points =
                                                          entry.value;

                                                      if (points.length < 2) {
                                                        return Polyline(
                                                            points: []);
                                                      }

                                                      return Polyline(
                                                        points: points,

                                                        strokeWidth: 5,

                                                        // ✅ GRADIENT-LIKE EFFECT (STRONG VISUAL)
                                                        color: Colors.blueAccent
                                                            .withValues(
                                                                alpha: 0.65),
                                                      );
                                                    }).toList(),
                                                  ),

                                                  // ✅ MARKERS (ON TOP)
                                                  MarkerLayer(
                                                    markers: markers,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),

                                // ✅ TOP FADE (PREMIUM LOOK)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 60,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.25),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // ✅ BOTTOM FADE (INTEGRATION)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 70,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.35),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =====================================================
                      // ✅ DEVICE LIST
                      // =====================================================

                      // ✅ SECTION TITLE (NEW ✅)
                      const Text(
                        "Your Devices",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ✅ DEVICE LIST CONTAINER (FIXED FLOW ✅)
                      SizedBox(
                        height: 450,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withValues(alpha: 0.02),
                          ),
                          child: ValueListenableBuilder<List<DeviceModel>>(
                            valueListenable: DeviceService.devicesNotifier,
                            builder: (context, devices, _) {
                              if (devices.isEmpty) {
                                return Center(child: _buildPremiumEmptyState());
                              }

                              return _buildPremiumDeviceList(devices);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ FLOAT BUTTON
          Positioned(bottom: 20, right: 20, child: _buildAddButton(context)),
        ],
      ),
    );
  }

  // =====================================================
  // ✅ PREMIUM EMPTY STATE (UPGRADED ✅)
  // =====================================================

  Widget _buildPremiumEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.devices,
                color: Color(0xFF38BDF8),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No devices yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tap + to add your first device",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

// =====================================================
// ✅ PREMIUM DEVICE LIST (FULL UI UPGRADE ✅)
// =====================================================

  Widget _buildPremiumDeviceList(List<DeviceModel> devices) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];

        final imeiFuture =
            _getImeiFuture(device.imei); // ✅ cached once per build

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              // ✅ ENHANCED GLASS GRADIENT (stable)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
              ),

              border: Border.all(color: Colors.white.withOpacity(0.08)),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================================
                // ✅ DEVICE HEADER
                // =====================================================
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ✅ FIX: removed useless SizedBox(height: 80)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            device.model,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    PopupMenuButton<String>(
                      color: const Color(0xFF1E293B),
                      onSelected: (value) {
                        if (value == "delete") {
                          _confirmDelete(device.id);
                        } else if (value == "edit") {
                          _editDevice(device);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: "edit",
                          child: Text(
                            "Edit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ IMEI TEXT
                Text(
                  "IMEI: ${device.imei}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 12),

                // =====================================================
                // ✅ IMEI STATUS (OPTIMIZED ✅)
                // =====================================================
                FutureBuilder<ImeiResult>(
                  future: imeiFuture, // ✅ uses cached future
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "Checking...",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    final result = snapshot.data!;
                    final status = result.status;

                    Color color;
                    IconData icon;

                    switch (status) {
                      case "Clean":
                        color = Colors.greenAccent;
                        icon = Icons.verified;
                        break;
                      case "Stolen":
                        color = Colors.redAccent;
                        icon = Icons.warning;
                        break;
                      case "Invalid":
                        color = Colors.grey;
                        icon = Icons.block;
                        break;
                      default:
                        color = Colors.orangeAccent;
                        icon = Icons.help_outline;
                    }

                    final isClean = status == "Clean";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: color.withOpacity(0.15),
                            border: Border.all(
                              color: color.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 16, color: color),
                              const SizedBox(width: 6),
                              Text(
                                status,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isClean)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: TextButton(
                              key: ValueKey(device.forSale),
                              onPressed: () => _toggleSell(device),
                              child: Text(
                                device.forSale
                                    ? "Remove from sale"
                                    : "Sell Device",
                                style: TextStyle(
                                  color: device.forSale
                                      ? Colors.redAccent
                                      : Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// =====================================================
// ✅ SELL / REMOVE (PREMIUM UI ✅)
// =====================================================

  void _toggleSell(DeviceModel device) async {
    if (device.forSale) {
      final updated = device.copyWith(
        forSale: false,
        price: null,
        description: null,
        contact: null,
      );

      await DeviceService.updateDevice(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from sale ✅")),
      );

      return;
    }

    String? location;
    String? frontImage;
    String? backImage;

    showDialog(
      context: context,
      builder: (context) {
        final priceController = TextEditingController();
        final descController = TextEditingController();
        final contactController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "List Device",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _input(
                      priceController,
                      "Price",
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _input(descController, "Description"),
                    const SizedBox(height: 10),
                    _input(contactController, "Contact"),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (v) => location = v,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Location"),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                              );

                              if (result != null) {
                                setState(() {
                                  frontImage = result.files.single.path;
                                });
                              }
                            },
                            child: const Text("Front Image"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                              );

                              if (result != null) {
                                setState(() {
                                  backImage = result.files.single.path;
                                });
                              }
                            },
                            child: const Text("Back Image"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (priceController.text.isEmpty ||
                        contactController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fill required fields"),
                        ),
                      );
                      return;
                    }

                    final updated = device.copyWith(
                      forSale: true,
                      price: double.tryParse(priceController.text),
                      description: descController.text,
                      contact: contactController.text,
                      location: location,
                      frontImage: frontImage,
                      backImage: backImage,
                    );

                    await DeviceService.updateDevice(updated);

                    if (!mounted) return;

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Device listed ✅")),
                    );
                  },
                  child: const Text("List Device"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // ✅ INPUT FIELD (UPGRADED ✅)
  // =====================================================

  Widget _input(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // =====================================================
  // ✅ EDIT DEVICE (CLEAN UI ✅)
  // =====================================================

  void _editDevice(DeviceModel device) {
    final controller = TextEditingController(text: device.model);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Edit Device",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration("Model"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;

                final updated = device.copyWith(model: controller.text);

                await DeviceService.updateDevice(updated);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Updated ✅")));
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // ✅ DELETE CONFIRM (POLISHED ✅)
  // =====================================================

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete Device",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to delete this device?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                await DeviceService.deleteDeviceById(id);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Deleted ✅")));
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // ✅ HEADER (FINAL POLISH ✅)
  // =====================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.devices, color: Color(0xFF38BDF8)),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Device Trust",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              "My Devices",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.store, color: Colors.white70),
          onPressed: () {
            Navigator.pushNamed(context, '/marketplace');
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white70),
          onPressed: _confirmLogout,
        ),
      ],
    );
  }

  // =====================================================
  // ✅ LOGOUT (UNCHANGED LOGIC, CLEAN UI ✅)
  // =====================================================

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Logout", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                await AuthService.logout();
                DeviceService.clearMemory();

                if (!mounted) return;

                Navigator.pop(context);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // ✅ FLOATING BUTTON (PREMIUM GLOW ✅)
  // =====================================================

  Widget _buildAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            final result = await Navigator.pushNamed(context, '/imei-benefits');

            if (!mounted) return;

            if (result == true) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Device added ✅")));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            child: const Icon(Icons.add, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
      ),
    );
  }

  // =====================================================
  // ✅ ACTION BUTTON (FINAL POLISH ✅)
  // =====================================================

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required List<Color> gradient,
    required bool isHover,
    required VoidCallback onEnter,
    required VoidCallback onExit,
  }) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(isHover ? 1.05 : 1.0),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(colors: gradient),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: isHover ? 0.7 : 0.4),
                blurRadius: isHover ? 22 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ✅ OUTLINED BUTTON (PREMIUM MOBILE-FIRST 🔥)
  // =====================================================

  Widget _outlinedActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isHover,
    required VoidCallback onEnter,
    required VoidCallback onExit,
  }) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(isHover ? 1.03 : 1.0),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.red.withValues(alpha: isHover ? 0.18 : 0.12),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: isHover ? 0.9 : 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: isHover ? 0.5 : 0.25),
                blurRadius: isHover ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ✅ FAMILY ACTIONS (PREMIUM UX ✅)
  // =====================================================

  void _createFamily() async {
    try {
      final code = await CircleService.createCircle("My Family");

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Family Created ✅",
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Share this invite code",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38BDF8),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Done"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  // =====================================================
  // ✅ JOIN FAMILY (UPGRADED FLOW ✅)
  // =====================================================

  void _showJoinDialog() {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Join Family",
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Invite code",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading) const CircularProgressIndicator(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                  ),
                  onPressed: () async {
                    if (controller.text.isEmpty) {
                      _showError("Enter invite code");
                      return;
                    }

                    setState(() => isLoading = true);

                    try {
                      await CircleService.joinCircle(controller.text);

                      if (!mounted) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Joined family ✅")),
                      );

                      await Future.delayed(const Duration(milliseconds: 300));
                      setState(() {});
                    } catch (e) {
                      Navigator.pop(context);
                      _showError(e.toString());
                    }
                  },
                  child: const Text("Join"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // ✅ ERROR HANDLING (IMPROVED ✅)
  // =====================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAnimatedMarker({
    required String id,
    required latlng.LatLng newPosition,
    required Widget child,
  }) {
    final oldPosition = _previousPositions[id] ?? newPosition;
    final latDiff = (newPosition.latitude - oldPosition.latitude).abs();
    final lngDiff = (newPosition.longitude - oldPosition.longitude).abs();

    final movement = latDiff + lngDiff;

    // ✅ detect moving vs idle
    final isMoving = movement > 0.00005;

    // ✅ dynamic speed
    final durationMs = movement < 0.0001
        ? 400
        : movement < 0.001
            ? 700
            : 1000;

    // ✅ calculate direction (bearing)
    final direction = math.atan2(
      newPosition.longitude - oldPosition.longitude,
      newPosition.latitude - oldPosition.latitude,
    );

    return TweenAnimationBuilder<latlng.LatLng>(
      tween: LatLngTween(begin: oldPosition, end: newPosition),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(
            (value.longitude - newPosition.longitude) * 80000,
            (value.latitude - newPosition.latitude) * -80000,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ✅ PULSE GLOW (ONLY WHEN MOVING)
              if (isMoving)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.4),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, scale, _) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withValues(alpha: 0.15),
                        ),
                      ),
                    );
                  },
                ),

              // ✅ DIRECTION ARROW
              if (isMoving)
                Transform.rotate(
                  angle: direction,
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),

              // ✅ MAIN MARKER
              AnimatedScale(
                scale: isMoving ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: child,
              ),

              // ✅ STATUS DOT (ONLINE INDICATOR)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMoving ? Colors.greenAccent : Colors.orange,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // ✅ CLEANUP
  // =====================================================

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}

// =====================================================
// ✅ GLOW EFFECT (UPGRADED SOFT DEPTH ✅)
// =====================================================

class _GlowCircle extends StatelessWidget {
  final Color color;

  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.18), Colors.transparent],
          radius: 0.8,
        ),
      ),
    );
  }
}

// =====================================================
// ✅ DEVICE CARD (ISOLATED REBUILD ✅)
// =====================================================

class _DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final Future<ImeiResult> imeiFuture;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggleSell;

  const _DeviceCard({
    required this.device,
    required this.imeiFuture,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleSell,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const Icon(Icons.phone_android, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      device.model,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "delete") onDelete();
                  if (value == "edit") onEdit();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: "edit", child: Text("Edit")),
                  PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "IMEI: ${device.imei}",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),

          const SizedBox(height: 10),

          FutureBuilder<ImeiResult>(
            future: imeiFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text(
                  "Checking...",
                  style: TextStyle(color: Colors.white54),
                );
              }

              final status = snapshot.data!.status;

              Color color = Colors.orange;
              if (status == "Clean") color = Colors.green;
              if (status == "Stolen") color = Colors.red;

              return Row(
                children: [
                  Icon(Icons.circle, size: 10, color: color),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(color: color),
                  ),
                  const Spacer(),
                  if (status == "Clean")
                    TextButton(
                      onPressed: onToggleSell,
                      child: Text(
                        device.forSale ? "Remove" : "Sell",
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class LatLngTween extends Tween<latlng.LatLng> {
  LatLngTween({required latlng.LatLng begin, required latlng.LatLng end})
      : super(begin: begin, end: end);

  @override
  latlng.LatLng lerp(double t) {
    return latlng.LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}
