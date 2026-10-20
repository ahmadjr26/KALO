import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/permission_utils.dart';
import '../../services/open_food_facts_service.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  late final MobileScannerController _scannerController;
  final OpenFoodFactsService _foodFactsService = OpenFoodFactsService();
  bool _isProcessing = false;
  bool _hasPermission = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await PermissionUtils.requestCameraPermission(
      context,
      reason: 'Camera permission is needed to scan food barcodes.',
    );
    if (!mounted) return;
    setState(() {
      _hasPermission = granted;
    });
    if (granted) {
      try {
        await _scannerController.start();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String barcode) async {
    final clean = barcode.trim();
    if (clean.isEmpty || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final meal = await _foodFactsService.fetchProductByBarcode(clean);
      if (!mounted) return;

      if (meal != null) {
        context.pushReplacement('/scan-result', extra: meal);
      } else {
        _showNotFoundDialog(clean);
      }
    } catch (e) {
      if (!mounted) return;
      _showNotFoundDialog(clean, error: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showManualBarcodeDialog() {
    final lang = ref.read(localeProvider);
    final isAr = lang == AppLanguage.arabic;
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          isAr ? 'إدخال رقم الباركود' : 'Enter Barcode Number',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: isAr ? 'مثال: 3017620422003' : 'e.g. 3017620422003 (Nutella)',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Nutella'),
                  onPressed: () {
                    textCtrl.text = '3017620422003';
                  },
                ),
                ActionChip(
                  label: const Text('Coca-Cola'),
                  onPressed: () {
                    textCtrl.text = '5449000000996';
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel', style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final code = textCtrl.text.trim();
              Navigator.pop(ctx);
              if (code.isNotEmpty) {
                _processBarcode(code);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
            ),
            child: Text(isAr ? 'بحث عن المنتج' : 'Lookup'),
          ),
        ],
      ),
    );
  }

  void _showNotFoundDialog(String barcode, {String? error}) {
    final lang = ref.read(localeProvider);
    final isAr = lang == AppLanguage.arabic;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  color: AppColors.warning,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  isAr ? 'المنتج غير موجود' : 'Product Not Found',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'لم يتم العثور على الباركود ($barcode) في قاعدة البيانات المفتوحة. يمكنك تصوير الوجبة أو إدخالها يدويًا.'
                      : 'Barcode $barcode was not found in the global OpenFoodFacts database. You can snap a photo or search manually.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isAr ? 'مسح مجددًا' : 'Scan Again',
                          style: const TextStyle(color: AppColors.text),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.pushReplacement('/food-search');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isAr ? 'بحث يدوي' : 'Search Food',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final isAr = lang == AppLanguage.arabic;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isAr ? 'مسح الباركود' : 'Scan Barcode',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_outlined, color: Colors.white),
            tooltip: isAr ? 'إدخال رقم الباركود' : 'Enter Barcode Manually',
            onPressed: _showManualBarcodeDialog,
          ),
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? AppColors.warning : Colors.white,
            ),
            onPressed: () async {
              try {
                await _scannerController.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              } catch (_) {}
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: !_hasPermission
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white54),
                    const SizedBox(height: 16),
                    Text(
                      isAr
                          ? 'إذن الكاميرا مطلوب لمسح الباركود'
                          : 'Camera access is required to scan barcodes.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _checkPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(isAr ? 'منح الإذن' : 'Grant Permission'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final codes = capture.barcodes;
                    if (codes.isNotEmpty && codes.first.rawValue != null) {
                      _processBarcode(codes.first.rawValue!);
                    }
                  },
                  errorBuilder: (context, error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.qr_code_scanner, color: AppColors.accent, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              isAr
                                  ? 'محاكي الكاميرا نشط. يمكنك إدخال الباركود يدويًا.'
                                  : 'Camera ready. Use viewfinder or enter barcode manually.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showManualBarcodeDialog,
                              icon: const Icon(Icons.keyboard),
                              label: Text(isAr ? 'إدخال رقم الباركود' : 'Type Barcode'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.6),
                    BlendMode.srcOut,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          backgroundBlendMode: BlendMode.dstOut,
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 280,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.accent, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isProcessing
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.accent),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 24,
                  right: 24,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            isAr
                                ? 'وجّه الكاميرا نحو باركود المنتج الغذائي'
                                : 'Align the barcode within the frame to scan',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
