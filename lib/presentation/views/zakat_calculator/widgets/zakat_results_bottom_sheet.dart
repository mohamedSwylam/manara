import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/bloc/zakat_calculator/zakat_calculator_state.dart';

class ZakatResultsBottomSheet extends StatelessWidget {
  final ZakatCalculatorLoaded result;

  const ZakatResultsBottomSheet({
    super.key,
    required this.result,
  });

  String _getCurrencySymbol() {
    switch (result.currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'QAR':
        return 'ر.ق';
      case 'KWD':
        return 'د.ك';
      case 'OMR':
        return 'ر.ع';
      case 'BHD':
        return 'د.ب';
      case 'JOD':
        return 'د.ا';
      default:
        return '\$';
    }
  }

  String _formatCurrency(double amount) {
    return '${_getCurrencySymbol()}${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with X button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  'Calculation Results',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          
          // Results content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                // Total Assets
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color?.withOpacity(0.3) ?? Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Assets',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _formatCurrency(result.totalAssets),
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Zakat Payable
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8D1B3D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8D1B3D),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zakat Payable',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8D1B3D),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        result.isZakatRequired 
                            ? _formatCurrency(result.zakatPayable)
                            : 'No Zakat Required',
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8D1B3D),
                        ),
                      ),
                      if (result.isZakatRequired) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Based on ${result.calculationBasis} calculation basis',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Additional info
                if (result.isZakatRequired) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Your net wealth (${_formatCurrency(result.netWealth)}) exceeds the Nisab threshold (${_formatCurrency(result.nisabThreshold)}). Zakat is calculated at 2.5% of your net wealth.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Your net wealth (${_formatCurrency(result.netWealth)}) is below the Nisab threshold (${_formatCurrency(result.nisabThreshold)}). No Zakat is required.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.orange[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
