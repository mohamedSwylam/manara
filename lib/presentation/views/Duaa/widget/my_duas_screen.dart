import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/fonts_weights.dart';
import 'duaa_card_widget.dart';

class  MyDuaaScreen extends StatelessWidget {
  const MyDuaaScreen({super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'my_duas'.tr,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeights.semiBold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,

      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView.separated(
          itemCount: duaas.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            return SizedBox(
              height: 260.h,
              child: DuaaCardWidget(
                title: duaas[index]['title']!,
                arabicText: duaas[index]['arabicText']!,
                englishText: duaas[index]['englishText']!,
                isFavorite: true,
                onFavoriteToggle: () {
                  // Handle favorite toggle
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

final List<Map<String, String>> duaas = [
  {
    'title': '1',
    'arabicText': 'اَللّٰهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
    'englishText': 'O Allah! I seek refuge in You from the decline of Your blessings...'
  },
  {
    'title': '2',
    'arabicText': 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    'englishText': 'I seek refuge in Allah from the accursed Satan'
  },
  {
    'title': '3',
    'arabicText': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
    'englishText': 'O Allah, send blessings upon Muhammad and the family of Muhammad'
  },
  {
    'title': '4',
    'arabicText': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    'englishText': 'Glory be to Allah and all praise is due to Him'
  },
];
