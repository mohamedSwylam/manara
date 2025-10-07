import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

enum StepperState { completed, current, upcoming }

class StepperStep {
  final String icon;
  final String label;
  final String time;
  final StepperState state;
  final Color? customColor;
  final double? customSize;

  const StepperStep({
    required this.icon,
    required this.label,
    required this.time,
    required this.state,
    this.customColor,
    this.customSize,
  });
}

class CurvedTimelineWidget extends StatelessWidget {
  final List<StepperStep> steps;
  final int currentStep;
  final Function(int)? onStepTapped;
  final Color? activeColor;
  final Color? nonActiveColor;
  final Color? completedColor;

  const CurvedTimelineWidget({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.activeColor,
    this.nonActiveColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultActiveColor = const Color(0xFFD4A574);
    final defaultNonActiveColor = theme.cardTheme.color ?? Colors.white;
    final defaultCompletedColor = const Color(0xFF8D1B3D);
    
    return SizedBox(
      width: 500.w,
      height: 130.h,
      child: Stack(
        children: [
          // Draw the half-oval arc with progress
                     CustomPaint(
             size: const Size(500, 130),
             painter: OvalArcPainter(
               progress: (currentStep + 1) / steps.length,
               completedColor: completedColor ?? defaultCompletedColor,
               backgroundColor: defaultNonActiveColor,
             ),
           ),
          // Steps along the arc - manually positioned
                     // Fajr (leftmost)
           Positioned(
             // left: 5.w, // Left side
             top: 90.h,  // Moved up from 68
             child: _buildStep(0, defaultNonActiveColor),
           ),
           // Sunrise
           Positioned(
             left: 55.w, // Between left and center
             top: 40.h,  // Moved up from 45
             child: _buildStep(1, defaultNonActiveColor),
           ),
           // Dhuhur
           Positioned(
             left: 130.w, // Center-left
             top: 30.h,   // Moved up from 35
             child: _buildStep(2, defaultNonActiveColor),
           ),
           // Asr
           Positioned(
             left: 190.w, // Center-right
             top: 30.h,   // Moved up from 35
             child: _buildStep(3, defaultNonActiveColor),
           ),
           // Maghrib
           Positioned(
             left: 240.w, // Between center and right
             top: 50.h,   // Moved up from 45
             child: _buildStep(4, defaultNonActiveColor),
           ),
           // Isha (rightmost)
           Positioned(
             left: 275.w, // Right side
             top: 85.h,   // Moved up from 68
             child: _buildStep(5, defaultNonActiveColor),
           ),
        ],
      ),
    );
  }

  Widget _buildStep(int index, Color nonActiveColor) {
    final step = steps[index];
    const defaultActiveColor = Color(0xFFD4A574);
    final defaultNonActiveColor = nonActiveColor;
    const defaultCompletedColor = Color(0xFF8D1B3D);

    return GestureDetector(
      onTap: () => onStepTapped?.call(index),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: step.state == StepperState.upcoming 
              ? Border.all(
                  color: defaultActiveColor,
                  width: 2,
                )
              : null,
        ),
        child: CircleAvatar(
          radius: step.customSize ?? 18,
          backgroundColor: _getStepColor(step, defaultActiveColor, defaultNonActiveColor, defaultCompletedColor),
          child: SvgPicture.asset(
            step.icon,
            height: (step.customSize ?? 18).h,
            colorFilter: ColorFilter.mode(
              _getIconColor(step, defaultCompletedColor),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStepColor(StepperStep step, Color defaultActiveColor, Color defaultNonActiveColor, Color defaultCompletedColor) {
    if (step.customColor != null) return step.customColor!;
    
    switch (step.state) {
      case StepperState.completed:
        return completedColor ?? defaultCompletedColor;
      case StepperState.current:
        return activeColor ?? defaultActiveColor;
      case StepperState.upcoming:
        return nonActiveColor ?? defaultNonActiveColor;
    }
  }

  Color _getIconColor(StepperStep step, Color defaultCompletedColor) {
    switch (step.state) {
      case StepperState.completed:
      case StepperState.current:
        return Colors.white;
      case StepperState.upcoming:
        return completedColor ?? defaultCompletedColor;
    }
  }
}

class OvalArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color completedColor;
  final Color backgroundColor;

  OvalArcPainter({
    required this.progress,
    required this.completedColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: const Offset(165, 120), // Match the center of the icons
      width: 310, // Reduced width to fit in card
      height: 140, // Reduced height to fit in card
    );

    // Draw border arc
    final borderPaint = Paint()
      ..color = const Color(0xFFD4A574)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, pi, pi, false, borderPaint);

    // Draw background arc (incomplete part)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, pi, pi, false, backgroundPaint);

    // Draw progress arc (completed part)
    final progressPaint = Paint()
      ..color = completedColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    // Calculate the end angle based on progress
    final endAngle = pi + (pi * progress);
    canvas.drawArc(rect, pi, endAngle - pi, false, progressPaint);
  }

  @override
  bool shouldRepaint(OvalArcPainter oldDelegate) => 
      oldDelegate.progress != progress || 
      oldDelegate.completedColor != completedColor ||
      oldDelegate.backgroundColor != backgroundColor;
} 
