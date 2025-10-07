import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/fonts_weights.dart';
import '../../data/viewmodel/Providers/location_provider.dart';
import '../../data/viewmodel/check_language_controller.dart';

class AzkarDetailsCardWidget extends StatelessWidget {
  const AzkarDetailsCardWidget({
    super.key,
    required this.azkarEnglish,
    required this.azkarArabic,
    required this.azkarTurkish,
    required this.azkarUrdu, required this.azkarBangla, required this.azkarFrench, required this.azkarHindi,
  });

  final String azkarEnglish;
  final String azkarArabic;
  final String azkarTurkish;
  final String azkarUrdu;
  final String azkarBangla;
  final String azkarFrench;
  final String azkarHindi;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context, listen:  false);
    return Card(
      color: AppColors.colorPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Text(
              azkarArabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            LanguageCheckingController.setLang == 'en'
                ? Text(
              azkarEnglish,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'tr'
                ? Text(
              azkarTurkish,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'ur' ? Text(
              azkarUrdu,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'bn' ? Text(
              azkarBangla,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'fr' ? Text(
              azkarFrench,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'hi' ? Text(
              azkarHindi,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : Text(
              azkarArabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

