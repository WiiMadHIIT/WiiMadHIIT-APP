import 'package:flutter/material.dart';

/// A reusable wheel picker widget with TikTok-style design
/// 
/// This widget provides a scrollable wheel picker with customizable appearance,
/// gradient overlays, and smooth animations. It's designed to be compact and
/// visually appealing for number selection in fitness apps.
class TikTokWheelPicker extends StatelessWidget {
  /// The label text displayed above the wheel picker
  final String label;
  
  /// The currently selected value
  final int value;
  
  /// The minimum value in the range
  final int min;
  
  /// The maximum value in the range
  final int max;
  
  /// Callback function called when the selected value changes
  final ValueChanged<int> onChanged;
  
  /// The primary color for the wheel picker
  final Color color;
  
  /// Whether to use compact mode (smaller dimensions)
  final bool compact;

  const TikTokWheelPicker({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.color,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = FixedExtentScrollController(initialItem: value - min);
    
    return Column(
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 13 : 15,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            )
          ),
          SizedBox(height: compact ? 6 : 8),
        ],
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: compact ? 60 : 70,
              height: compact ? 80 : 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.1), width: 1),
              ),
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: compact ? 28 : 44,
                diameterRatio: 1.2,
                physics: FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) => onChanged(i + min),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, i) {
                    final v = i + min;
                    final isSelected = v == value;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: isSelected
                          ? BoxDecoration(
                              color: color.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color, width: 2),
                            )
                          : null,
                      child: Text(
                        v.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? (compact ? 24 : 32) : (compact ? 16 : 20),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? color : Colors.black54,
                          letterSpacing: 1.1,
                        ),
                      ),
                    );
                  },
                  childCount: max - min + 1,
                ),
              ),
            ),
            // Top gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: compact ? 24 : 28,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: compact ? 24 : 28,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 