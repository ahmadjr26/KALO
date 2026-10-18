import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock_database.dart';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedModeIndex = 0; // 0: Food, 1: Barcode, 2: Label, 3: Voice
  bool _isFlashOn = false;
  bool _isAnalyzing = false;
  late AnimationController _pulseController;

  final List<String> _modes = ['Food Scan', 'Barcode', 'Nutrition Label', 'Voice'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerCapture() async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    // Simulate AI Vision decomposition latency (800ms)
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    // Pass detected meal breakdown to Result Screen S17
    final sampleMeal = MockDatabase.visionSamplePrescriptions.first;
    context.push('/scan-result', extra: sampleMeal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Viewfinder Stream
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF141923), Color(0xFF090C11), Color(0xFF000000)],
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: 0.25,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lunch_dining_rounded, size: 100, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      'AI Vision Camera Active',
                      style: AppTypography.sm.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Central Food Reticle Brackets
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final double glow = 0.5 + (_pulseController.value * 0.5);

                return SizedBox(
                  width: 270,
                  height: 270,
                  child: Stack(
                    children: [
                      // Top Left Bracket
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _BracketCorner(
                          isTop: true,
                          isLeft: true,
                          color: _isAnalyzing
                              ? AppColors.warning
                              : AppColors.accent.withValues(alpha: glow),
                        ),
                      ),
                      // Top Right Bracket
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _BracketCorner(
                          isTop: true,
                          isLeft: false,
                          color: _isAnalyzing
                              ? AppColors.warning
                              : AppColors.accent.withValues(alpha: glow),
                        ),
                      ),
                      // Bottom Left Bracket
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _BracketCorner(
                          isTop: false,
                          isLeft: true,
                          color: _isAnalyzing
                              ? AppColors.warning
                              : AppColors.accent.withValues(alpha: glow),
                        ),
                      ),
                      // Bottom Right Bracket
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _BracketCorner(
                          isTop: false,
                          isLeft: false,
                          color: _isAnalyzing
                              ? AppColors.warning
                              : AppColors.accent.withValues(alpha: glow),
                        ),
                      ),
                      if (_isAnalyzing)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(200),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Analyzing meal...',
                                  style: AppTypography.xs.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Top Camera Controls (Back, Flash, Gallery)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() => _isFlashOn = !_isFlashOn);
                        },
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: _isFlashOn ? AppColors.warning : Colors.white,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: _triggerCapture,
                        icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Shutter & Mode Switcher
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mode Carousel
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_modes.length, (index) {
                      final bool isSelected = index == _selectedModeIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedModeIndex = index);
                          if (index == 1) context.push('/barcode-scanner');
                          if (index == 2) context.push('/label-scanner');
                          if (index == 3) context.push('/voice-log');
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withAlpha(50) : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _modes[index],
                            style: TextStyle(
                              color: isSelected ? AppColors.accent : Colors.white70,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // Shutter Button
                GestureDetector(
                  key: const Key('shutter_button'),
                  onTap: _triggerCapture,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isAnalyzing ? AppColors.accent : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to scan plate',
                        style: AppTypography.xs.copyWith(color: Colors.white60),
                      ),
                    ],
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

class _BracketCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  final Color color;

  const _BracketCorner({
    required this.isTop,
    required this.isLeft,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double length = 32.0;
    const double thickness = 3.5;

    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          // Horizontal Arm
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: length,
              height: thickness,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Vertical Arm
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: thickness,
              height: length,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
