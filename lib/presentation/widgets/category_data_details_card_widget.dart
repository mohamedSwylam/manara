import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/fonts_weights.dart';
import '../../data/viewmodel/Providers/location_provider.dart';
import '../../data/viewmodel/check_language_controller.dart';

class CategoryDataDetailsCardWidget extends StatelessWidget {
  const CategoryDataDetailsCardWidget({
    super.key,
    this.authorName,
    required this.amolEnglish,
    required this.amolArabic,
    required this.amolTurkish,
    required this.amolUrdu,
    required this.title,
    required this.amolBangla,
    required this.amolFrench,
    required this.amolHindi,
  });

  final String? authorName;
  final String amolEnglish;
  final String amolArabic;
  final String amolTurkish;
  final String amolUrdu;
  final String amolBangla;
  final String amolFrench;
  final String amolHindi;
  final String title;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context, listen:  false);
    return Card(
      color: AppColors.colorPrimaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            ),
            authorName != null
                ? Text(
                    authorName!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.colorPrimaryLighter,
                      fontSize: 16.sp,
                      fontWeight: FontWeights.semiBold,
                    ),
                  )
                : const SizedBox(
                    height: 0,
                  ),
            const SizedBox(
              height: 16,
            ),
            Container(
              color: AppColors.colorWhiteHighEmp,
              height: 0.5,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              amolArabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            ),
            const SizedBox(height: 5),
            LanguageCheckingController.setLang == 'en'
                ? Text(
              amolEnglish,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'tr'
                ? Text(
              amolTurkish,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'ur' ? Text(
              amolUrdu,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'bn' ? Text(
              amolBangla,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'fr' ? Text(
              amolEnglish,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : LanguageCheckingController.setLang == 'hi' ? Text(
              amolHindi,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.colorWhiteHighEmp,
                fontSize: 14.sp,
                fontWeight: FontWeights.regular,
              ),
            )
                : Text(
              amolArabic,
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


