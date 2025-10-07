import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrencyDropdown extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencyChanged;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currencies = [
      {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
      {'code': 'SAR', 'name': 'Saudi Riyal', 'symbol': 'ر.س'},
      {'code': 'AED', 'name': 'UAE Dirham', 'symbol': 'د.إ'},
      {'code': 'QAR', 'name': 'Qatar Riyal', 'symbol': 'ر.ق'},
      {'code': 'KWD', 'name': 'Kuwaiti Dinar', 'symbol': 'د.ك'},
      {'code': 'OMR', 'name': 'Omani Rial', 'symbol': 'ر.ع'},
      {'code': 'BHD', 'name': 'Bahraini Dinar', 'symbol': 'د.ب'},
      {'code': 'JOD', 'name': 'Jordanian Dinar', 'symbol': 'د.ا'},
    ];

    return Container(
      width: 328.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCurrency,
          isExpanded: true,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(8),
          items: currencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency['code'],
              child: Row(
                children: [
                  Text(
                    currency['symbol']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${currency['code']} - ${currency['name']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onCurrencyChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}
