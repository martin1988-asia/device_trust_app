import 'package:flutter/material.dart';
import '../../models/device_model.dart';
import '../../services/device_service.dart';
import '../../services/imei_service.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage>
    with SingleTickerProviderStateMixin {
  final imeiController = TextEditingController();
  final modelController = TextEditingController();

  String? selectedBrand;
  String? selectedColor;
  String? error;

  bool _isSaving = false;
  bool _success = false;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<double> _slide;

  final List<String> brands = [
    "Samsung",
    "iPhone",
    "Huawei",
    "Xiaomi",
    "Tecno",
    "Infinix",
    "Oppo",
    "Vivo",
    "Nokia",
    "Motorola",
  ];

  final List<String> colors = [
    "Black",
    "Silver",
    "Blue",
    "Red",
    "Gold",
    "White",
    "Green",
  ];

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fade = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOut,
    );

    _slide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
  }

  // =====================================================
  // ✅ VALIDATION
  // =====================================================

  bool get _isFormValid {
    return selectedBrand != null &&
        modelController.text.trim().isNotEmpty &&
        _validateImei() == null;
  }

  // =====================================================
  // ✅ SAVE DEVICE (FIXED ✅)
  // =====================================================

  Future<void> saveDevice() async {
    if (!_isFormValid) {
      setState(() => error = "Complete all required fields");
      return;
    }

    final imei = imeiController.text.trim();
    final model = modelController.text.trim();

    setState(() {
      _isSaving = true;
      error = null;
    });

    try {
      final result = await ImeiService.checkStatus(imei);

      if (result.status == "Invalid") {
        setState(() {
          _isSaving = false;
          error = "Invalid IMEI";
        });
        return;
      }

      final device = DeviceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: selectedBrand!,
        imei: imei,
        model: model,
      );

      await DeviceService.addDevice(device);

      if (!mounted) return;

      setState(() => _success = true);

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        error = e.toString().replaceAll("Exception:", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // ✅ BACKGROUND
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF020617), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FadeTransition(
                  opacity: _fade,
                  child: Transform.translate(
                    offset: Offset(0, _slide.value),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ================= HEADER =================
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
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
                                color: Colors.white.withValues(alpha: 0.04),
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
                                    onChanged: (v) =>
                                        setState(() => selectedBrand = v),
                                  ),
                                  const SizedBox(height: 14),
                                  _inputField(
                                    controller: modelController,
                                    hint: "Model (e.g. Galaxy S25)",
                                  ),
                                  const SizedBox(height: 14),
                                  _inputField(
                                    controller: imeiController,
                                    hint: "IMEI (15 digits)",
                                    isNumber: true,
                                    errorText: _validateImei(),
                                  ),
                                  const SizedBox(height: 14),
                                  _styledDropdown<String>(
                                    value: selectedColor,
                                    hint: "Color (optional)",
                                    items: colors,
                                    onChanged: (v) =>
                                        setState(() => selectedColor = v),
                                  ),
                                  if (error != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ],
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: (!_isFormValid || _isSaving)
                                        ? null
                                        : saveDevice,
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: _success
                                          ? const Icon(Icons.check)
                                          : _isSaving
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text("Save Device"),
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
    bool isNumber = false,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
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
  // ✅ IMEI VALIDATION
  // =====================================================

  String? _validateImei() {
    final value = imeiController.text.trim();

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
      initialValue: value,
      dropdownColor: const Color(0xFF1E293B),
      style: const TextStyle(color: Colors.white),
      hint: Text(hint, style: const TextStyle(color: Colors.white70)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    imeiController.dispose();
    modelController.dispose();
    _anim.dispose();
    super.dispose();
  }
}
