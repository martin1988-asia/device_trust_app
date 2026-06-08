import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

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

  StreamSubscription<Position>? _positionStream;

  List<UserModel> _circleUsers = [];

  bool _isLocateHover = false;
  bool _isStopHover = false;
  bool _mapReady = false;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    _getLocation();
    _loadDevices();
  }

  // =====================================================
  // ✅ DEVICE LOADER (UPGRADED SAFE ✅)
  // =====================================================

  Future<void> _loadDevices() async {
    try {
      print("📦 Loading devices...");

      await DeviceService.loadDevices()
          .timeout(const Duration(seconds: 5));

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

      
      Future.delayed(const Duration(milliseconds: 300), _animateCamera);


      await AuthService.updateLocation(pos.latitude, pos.longitude);
    });
  }

  void _animateCamera() {
    if (!_mapReady || _lat == null || _lng == null) return;

    try {
      _mapController.move(
        LatLng(_lat!, _lng!),
        13,
      );
    } catch (_) {

    }
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
  // ✅ BUILD (FULL PREMIUM UI ✅)
  // =====================================================

  @override
  Widget build(BuildContext context) {

    if (_isLoadingDevices) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
                          const Column(
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

                          const Spacer(),

                          // ✅ ACTION BUTTONS (UPGRADED 🔥)
                          Row(
                            children: [

                              _headerAction(
                                icon: Icons.storefront,
                                tooltip: "Marketplace",
                                onTap: () {
                                  Navigator.pushNamed(context, '/marketplace');
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
                        ],
                      ),

                      const SizedBox(height: 20),

                      // =====================================================
                      // ✅ ACTION BUTTONS
                      // =====================================================

                      Row(
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
                                  future: CircleService.getMyCircle(),
                                  builder: (context, circleSnapshot) {

                                    if (!circleSnapshot.hasData || circleSnapshot.data == null) {
                                      return const Center(
                                        child: Text(
                                          "No family circle found",
                                          style: TextStyle(color: Colors.white54),
                                        ),  
                                      );
                                    }

                                    final circle = circleSnapshot.data!;
                                    final members = circle.memberIds;


                                    return StreamBuilder(
                                      stream: LocationService.streamLocations(members),
                                      builder: (context, locationSnapshot) {

                                        if (!locationSnapshot.hasData) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final docs = locationSnapshot.data!.docs;

                                        if (docs.isEmpty) {
                                          return const Center(
                                            child: Text(
                                              "Waiting for live locations...",
                                              style: TextStyle(color: Colors.white54),
                                            ),
                                          );
                                        }

                                        final markers = docs.map((doc) {
                                          final data = doc.data() as Map<String, dynamic>;

                                          final lat = data['lat'];
                                          final lng = data['lng'];

                                          if (lat == null || lng == null) return null;

                                          return Marker(
                                            point: LatLng(lat, lng),
                                            width: 50,
                                            height: 50,

                                            child: Column(
                                              children: [

                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blueAccent,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.blueAccent
                                                            .withValues(alpha: 0.5),
                                                        blurRadius: 12,
                                                      )
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  doc.id,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).whereType<Marker>().toList();

                                        return FlutterMap(
                                          mapController: _mapController,
                                          options: MapOptions(
                                            initialCenter: markers.isNotEmpty
                                                ? markers.first.point
                                                : LatLng(_lat ?? 0, _lng ?? 0),
                                            initialZoom: 13,
                                            onMapReady: () {
                                              _mapReady = true;
                                            },
                                          ),

                                          children: [
                                            TileLayer(
                                              urlTemplate:
                                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                            ),

                                            MarkerLayer(markers: markers),
                                          ],
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
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color:
                                Colors.white.withValues(alpha: 0.02),
                          ),

                          child: ValueListenableBuilder<List<DeviceModel>>(
                            valueListenable:
                                DeviceService.devicesNotifier,

                            builder: (context, devices, _) {
                              if (devices.isEmpty) {
                                return Center(
                                  child:
                                      _buildPremiumEmptyState(),
                                );
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
          Positioned(
            bottom: 30,
            right: 30,
            child: _buildAddButton(context),
          ),
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
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ✅ PREMIUM DEVICE LIST (FULL UI UPRADE ✅)
  // =====================================================

  Widget _buildPremiumDeviceList(List<DeviceModel> devices) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: devices.length,

      itemBuilder: (context, index) {
        final device = devices[index];

        return MouseRegion(
          cursor: SystemMouseCursors.click,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),

            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              // ✅ ENHANCED GLASS GRADIENT
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),

              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
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
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.phone_android,
                        color: Colors.white70),
                  ),

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
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
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
                        child: Text("Edit",
                            style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete",
                            style: TextStyle(color: Colors.redAccent)),
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
              // ✅ IMEI STATUS (UPGRADED UI ✅)
              // =====================================================

              FutureBuilder<ImeiResult>(
                future: ImeiService.checkStatus(device.imei),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      "Checking...",
                      style: TextStyle(color: Colors.white54),
                    );
                  }

                  final result = snapshot.data!;
                  final status = result.status;

                  Color color;
                  IconData icon;

                  switch (status) {
                    case "Clean":
                      color = Colors.green;
                      icon = Icons.verified;
                      break;
                    case "Stolen":
                      color = Colors.red;
                      icon = Icons.warning;
                      break;
                    case "Invalid":
                      color = Colors.grey;
                      icon = Icons.block;
                      break;
                    default:
                      color = Colors.orange;
                      icon = Icons.help_outline;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: color.withValues(alpha: 0.15),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (status == "Clean")
                        TextButton(
                          onPressed: () => _toggleSell(device),

                          child: Text(
                            device.forSale
                                ? "Remove from sale"
                                : "Sell Device",

                            style: TextStyle(
                              color: device.forSale
                                  ? Colors.redAccent
                                  : Colors.blueAccent,
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

    final priceController = TextEditingController();
    final descController = TextEditingController();
    final contactController = TextEditingController();

    String? location;
    String? frontImage;
    String? backImage;

    showDialog(
      context: context,
      builder: (_) {
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

                _input(priceController, "Price",
                    keyboard: TextInputType.number),

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
                            frontImage =
                                result.files.single.path;
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
                            backImage =
                                result.files.single.path;
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
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white70)),
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
                  price:
                      double.tryParse(priceController.text),
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
                  const SnackBar(
                      content: Text("Device listed ✅")),
                );
              },
              child: const Text("List Device"),
            ),
          ],
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
    final controller =
        TextEditingController(text: device.model);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text("Edit Device",
              style: TextStyle(color: Colors.white)),

          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration("Model"),
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white70)),
            ),

            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;

                final updated =
                    device.copyWith(model: controller.text);

                await DeviceService.updateDevice(updated);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Updated ✅")),
                );
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

          title: const Text("Delete Device",
              style: TextStyle(color: Colors.white)),

          content: const Text(
            "Are you sure you want to delete this device?",
            style: TextStyle(color: Colors.white70),
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white70)),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),

              onPressed: () async {
                await DeviceService.deleteDeviceById(id);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Deleted ✅")),
                );
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
          child: const Icon(
            Icons.devices,
            color: Color(0xFF38BDF8),
          ),
        ),

        const SizedBox(width: 12),

        const Column(
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

          title: const Text("Logout",
              style: TextStyle(color: Colors.white)),

          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white70),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white70)),
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
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
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
          colors: [
            Color(0xFF38BDF8),
            Color(0xFF6366F1),
          ],
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Device added ✅")),
              );
            }
          },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,

            padding: const EdgeInsets.all(14),

            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 26,
            ),
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
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),

        child: Icon(
          icon,
          color: Colors.white70,
          size: 18,
        ),
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
          transform:
              Matrix4.identity()..scale(isHover ? 1.05 : 1.0),

          padding: const EdgeInsets.symmetric(vertical: 14),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(colors: gradient),

            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(
                    alpha: isHover ? 0.7 : 0.4),
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
  // ✅ OUTLINED BUTTON (IMPROVED ✅)
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
          duration: const Duration(milliseconds: 180),
          transform:
              Matrix4.identity()..scale(isHover ? 1.05 : 1.0),

          padding: const EdgeInsets.symmetric(vertical: 14),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.red.withValues(alpha: 0.12),
            border: Border.all(color: Colors.redAccent),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stop_circle,
                  color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.redAccent,
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
// ✅ FAMILY ACTIONS (CREATE / JOIN)
// =====================================================

void _createFamily() async {
  try {
    final code = await CircleService.createCircle("My Family");

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Family Created ✅"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Share this invite code:"),
              const SizedBox(height: 10),
              SelectableText(
                code,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  } catch (e) {
    _showError(e.toString());
  }
}

void _showJoinDialog() {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Join Family"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter invite code",
          ),
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {
              try {
                await CircleService.joinCircle(controller.text);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Joined family ✅")),
                );

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
}

void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
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
// ✅ GLOW EFFECT (UNCHANGED, WORKS PERFECT ✅)
// =====================================================

class _GlowCircle extends StatelessWidget {
  final Color color;

  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}
