import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalculationBasisSelector extends StatelessWidget {
  final String selectedBasis;
  final Function(String) onBasisChanged;

  const CalculationBasisSelector({
    super.key,
    required this.selectedBasis,
    required this.onBasisChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 328.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Gold Option
          Expanded(
            child: GestureDetector(
              onTap: () => onBasisChanged('Gold'),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selectedBasis == 'Gold'
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Gold',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: selectedBasis == 'Gold'
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Silver Option
          Expanded(
            child: GestureDetector(
              onTap: () => onBasisChanged('Silver'),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selectedBasis == 'Silver'
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Silver',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: selectedBasis == 'Silver'
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
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
}
