import 'package:flutter/material.dart';
import '../../models/device_model.dart';
import '../../services/device_service.dart';
import '../../services/imei_service.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {

  final imeiController = TextEditingController();
  final modelController = TextEditingController();

  String? selectedBrand;
  String? selectedColor;

  String? error;

  bool _isSaving = false;
  bool _success = false;

  final List<String> brands = [
    "Samsung","iPhone","Huawei","Xiaomi","Tecno",
    "Infinix","Oppo","Vivo","Nokia","Motorola",
  ];

  final List<String> colors = [
    "Black","Silver","Blue","Red","Gold","White","Green",
  ];

  // =====================================================
  // ✅ VALIDATION
  // =====================================================

  bool get _isFormValid {
    return selectedBrand != null &&
        modelController.text.isNotEmpty &&
        _validateImei() == null;
  }

  // =====================================================
  // ✅ SAVE DEVICE (FULLY FIXED ✅)
  // =====================================================

  Future<void> saveDevice() async {
    if (!_isFormValid) {
      setState(() => error = "Complete all required fields");
      return;
    }

    final result =
        await ImeiService.checkStatus(imeiController.text);

    if (result.status == "Invalid") {
      setState(() => error = "Invalid IMEI");
      return;
    }

    final device = DeviceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: selectedBrand!,
      imei: imeiController.text,
      model: modelController.text,
    );

    setState(() {
      _isSaving = true;
      error = null;
    });

    try {
      await DeviceService.addDevice(device);

      if (!mounted) return;

      // ✅ SUCCESS STATE
      setState(() {
        _success = true;
      });

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/devices');
    } catch (e) {

      // ✅ AUTO CLEAR FORM
      imeiController.clear();
      modelController.clear();
      selectedBrand = null;
      selectedColor = null;

      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/devices');

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // ✅ GLOW
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

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      // ✅ HEADER
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),

                          const SizedBox(width: 8),

                          const Text(
                            "Add Device",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,

                            children: [

                              const Text(
                                "Register New Device",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 18),

                              _styledDropdown<String>(
                                value: selectedBrand,
                                hint: "Select Brand",
                                items: brands,
                                onChanged: (value) {
                                  setState(() => selectedBrand = value);
                                },
                              ),

                              const SizedBox(height: 14),

                              _inputField(
                                controller: modelController,
                                hint: "Model (e.g. Galaxy S25)",
                              ),

                              const SizedBox(height: 14),

                              TextField(
                                controller: imeiController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),

                                onChanged: (_) => setState(() {}),

                                decoration: InputDecoration(
                                  hintText: "IMEI (15 digits)",
                                  errorText: _validateImei(),

                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.08),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),


const SizedBox(height: 14),

                              _styledDropdown<String>(
                                value: selectedColor,
                                hint: "Color (optional)",
                                items: colors,
                                onChanged: (value) {
                                  setState(() => selectedColor = value);
                                },
                              ),

                              if (error != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],

                              const Spacer(),

                              // ✅ SAVE BUTTON (SMART + PREMIUM ✅)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),

                                child: ElevatedButton(
                                  onPressed:
                                      (!_isFormValid || _isSaving)
                                          ? null
                                          : saveDevice,

                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),

                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),

                                    child: _success
                                        ? const Icon(
                                            Icons.check,
                                            key: ValueKey("success"),
                                            color: Colors.white,
                                          )

                                        : _isSaving
                                            ? const SizedBox(
                                                key: ValueKey("loading"),
                                                height: 18,
                                                width: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )

                                            : const Text(
                                                "Save Device",
                                                key: ValueKey("text"),
                                              ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ✅ INPUT FIELD
  // =====================================================

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),

      onChanged: (_) => setState(() {}),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),

        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // =====================================================
  // ✅ IMEI VALIDATION (LIVE ✅)
  // =====================================================

  String? _validateImei() {
    final value = imeiController.text;

    if (value.isEmpty) return null;

    if (value.length != 15) {
      return "IMEI must be 15 digits";
    }

    if (int.tryParse(value) == null) {
      return "IMEI must be numeric";
    }

    return null;
  }

  // =====================================================
  // ✅ DROPDOWN
  // =====================================================

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: const Color(0xFF1E293B),

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      hint: Text(
        hint,
        style: const TextStyle(color: Colors.white70),
      ),

      items: items.map((e) {
        return DropdownMenuItem<T>(
          value: e,
          child: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }

  // =====================================================
  // ✅ CLEANUP
  // =====================================================

  @override
  void dispose() {
    imeiController.dispose();
    modelController.dispose();
    super.dispose();
  }
}

// =====================================================
// ✅ GLOW BACKGROUND
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

