import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class KeepScreenOnBottomSheet extends StatefulWidget {
  final String currentSelection;

  const KeepScreenOnBottomSheet({
    super.key,
    required this.currentSelection,
  });

  static Future<String?> show(BuildContext context, {required String currentSelection}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => KeepScreenOnBottomSheet(currentSelection: currentSelection),
    );
  }

  @override
  State<KeepScreenOnBottomSheet> createState() => _KeepScreenOnBottomSheetState();
}

class _KeepScreenOnBottomSheetState extends State<KeepScreenOnBottomSheet> {
  late String selectedOption;

  final List<String> options = [
    'Disabled',
    'Follow phone settings',
    'Always on when playing audio',
  ];

  @override
  void initState() {
    super.initState();
    selectedOption = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Keep Screen On',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: theme.textTheme.titleMedium?.color ?? Colors.black,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Options List
          Container(
            padding: EdgeInsets.only(bottom: 32.h),
            child: Column(
              children: options.map((option) => _buildOptionItem(option)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(String option) {
    final theme = Theme.of(context);
    final isSelected = selectedOption == option;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
        // Here you would typically save the selection and update the UI
        print('Selected: $option');
        Get.back(result: option);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: isSelected ? (theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100]) : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 20.sp,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}
