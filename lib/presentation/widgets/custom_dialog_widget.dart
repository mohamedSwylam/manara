import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDialogWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String firstChoiceText;
  final String secondChoiceText;
  final VoidCallback? onFirstChoicePressed;
  final VoidCallback? onSecondChoicePressed;
  final Color? firstChoiceColor;
  final Color? secondChoiceColor;

  const CustomDialogWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.firstChoiceText,
    required this.secondChoiceText,
    this.onFirstChoicePressed,
    this.onSecondChoicePressed,
    this.firstChoiceColor,
    this.secondChoiceColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 328.w,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with X button
            Padding(
              padding: EdgeInsets.only(
                top: 16.h,
                right: 16.w,
                left: 16.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  height: 20.h / 15.sp,
                  color: theme.textTheme.titleMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Subtitle (optional)
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    height: 20.h / 13.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            
            SizedBox(height: 16.h),
            
            // Choices container
            Container(
              width: 296.w,
              height: 88.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.dividerTheme.color ?? Colors.grey[300]!,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // First choice
                  Expanded(
                    child: InkWell(
                      onTap: onFirstChoicePressed ?? () => Navigator.of(context).pop(),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Center(
                          child: Text(
                            firstChoiceText,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                              height: 20.h / 13.sp,
                              color: firstChoiceColor ?? const Color(0xFFE33C3C),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: theme.dividerTheme.color,
                  ),
                  
                  // Second choice
                  Expanded(
                    child: InkWell(
                      onTap: onSecondChoicePressed ?? () => Navigator.of(context).pop(),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Center(
                          child: Text(
                            secondChoiceText,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                              height: 20.h / 13.sp,
                              color: secondChoiceColor ?? const Color(0xFF4F4F4F),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // Static method to show the dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required String firstChoiceText,
    required String secondChoiceText,
    VoidCallback? onFirstChoicePressed,
    VoidCallback? onSecondChoicePressed,
    Color? firstChoiceColor,
    Color? secondChoiceColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialogWidget(
        title: title,
        subtitle: subtitle,
        firstChoiceText: firstChoiceText,
        secondChoiceText: secondChoiceText,
        onFirstChoicePressed: onFirstChoicePressed,
        onSecondChoicePressed: onSecondChoicePressed,
        firstChoiceColor: firstChoiceColor,
        secondChoiceColor: secondChoiceColor,
      ),
    );
  }
}
