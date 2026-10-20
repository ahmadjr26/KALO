import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WeightRulerPicker extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String unit;

  const WeightRulerPicker({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.min = 35.0,
    this.max = 200.0,
    this.unit = 'Kg',
  });

  @override
  State<WeightRulerPicker> createState() => _WeightRulerPickerState();
}

class _WeightRulerPickerState extends State<WeightRulerPicker> {
  late ScrollController _scrollController;
  late double _currentValue;
  static const double _itemWidth = 14.0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.min, widget.max);
    final initialIndex = (_currentValue - widget.min);
    _scrollController = ScrollController(
      initialScrollOffset: initialIndex * _itemWidth,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final index = (offset / _itemWidth).round();
    final newValue = (widget.min + index).clamp(widget.min, widget.max);
    if (newValue != _currentValue) {
      HapticFeedback.selectionClick();
      setState(() => _currentValue = newValue);
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = (widget.max - widget.min).toInt() + 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Huge bold typography readout matching Figma frame 1:1160
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _currentValue.toStringAsFixed(0),
              style: AppTypography.displayHeadline(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.unit,
              style: AppTypography.md.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Ruler viewport with center indicator
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    _onScroll();
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: (MediaQuery.of(context).size.width - 48) / 2 - (_itemWidth / 2),
                  ),
                  itemCount: totalSteps,
                  itemBuilder: (context, i) {
                    final isMajor = i % 5 == 0;
                    return Container(
                      width: _itemWidth,
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: isMajor ? 2.5 : 1.5,
                            height: isMajor ? 36 : 18,
                            decoration: BoxDecoration(
                              color: isMajor ? AppColors.text : AppColors.borderInput,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          if (isMajor) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${(widget.min + i).toInt()}',
                              style: AppTypography.xs.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Active needle in Center (Figma Coral/Lime indicator)
            IgnorePointer(
              child: Container(
                width: 3.5,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(100),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
