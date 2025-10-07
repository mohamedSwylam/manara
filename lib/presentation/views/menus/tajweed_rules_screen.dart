import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TajweedRulesScreen extends StatefulWidget {
  const TajweedRulesScreen({super.key});

  @override
  State<TajweedRulesScreen> createState() => _TajweedRulesScreenState();
}

class _TajweedRulesScreenState extends State<TajweedRulesScreen> {
  final List<Map<String, dynamic>> tajweedRules = [
    {
      'color': const Color(0xFFB50101), // #B50101
      'arabicText': 'مد 6 حركات لزوماً',
      'englishTitle': 'Madd (prolongation)',
      'englishSubtitle': '6 Beats (compulsory)',
    },
    {
      'color': const Color(0xFFF30100), // #F30100
      'arabicText': 'مد واجب 4 او 5 حركات',
      'englishTitle': 'Madd 4 or 5 Beats',
      'englishSubtitle': '(Mandatory)',
    },
    {
      'color': const Color(0xFFCA9B02), // #CA9B02
      'arabicText': 'مد 2 او 4 او 7 جوازاً',
      'englishTitle': 'Madd 2 or 4 or 6 Beats',
      'englishSubtitle': '(Permitted)',
    },
    {
      'color': const Color(0xFFFF7B02), // #FF7B02
      'arabicText': 'مد حركتان',
      'englishTitle': 'Madd 2 or 4 or 6 Beats',
      'englishSubtitle': '(Permitted)',
    },
    {
      'color': const Color(0xFF0CB002), // #0CB002
      'arabicText': 'أخفاء و مواقع الغنة (حركتان)',
      'englishTitle': 'Ghunna (Nasal Sound)',
      'englishSubtitle': 'With Ikhfaa (Hiding)',
    },
    {
      'color': const Color(0xFF8E8E8E), // #8E8E8E
      'arabicText': 'ادغام و مالا يلفظ',
      'englishTitle': 'Idghaam (Mixing)',
      'englishSubtitle': 'With Silent Letter',
    },
    {
      'color': const Color(0xFF2EADFF), // #2EADFF
      'arabicText': 'تفخيم الراء',
      'englishTitle': 'Tafkheem Ar-Raa',
      'englishSubtitle': 'Heavy Raa',
    },
    {
      'color': const Color(0xFF2EADFF), // #2EADFF
      'arabicText': 'قلقلة',
      'englishTitle': 'Qalqalah',
      'englishSubtitle': '(Vibration)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Tajweed Rules',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 32.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
          ),
                     child: ListView.builder(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             itemCount: tajweedRules.length,
             itemBuilder: (context, index) {
               final rule = tajweedRules[index];
               return _buildTajweedRuleItem(rule);
             },
           ),
        ),
      ),
    );
  }

  Widget _buildTajweedRuleItem(Map<String, dynamic> rule) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
                     // Color Swatch
           Container(
             width: 40.w,
             height: 60.h,
             decoration: BoxDecoration(
               color: rule['color'],
               borderRadius: BorderRadius.circular(6),
             ),
           ),
          
          SizedBox(width: 12.w),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                 // Arabic Text
                 Text(
                   rule['arabicText'],
                   style: TextStyle(
                     fontFamily: 'IBM Plex Sans Arabic',
                     fontWeight: FontWeight.w500, // Medium
                     fontSize: 13.sp,
                     height: 20 / 13, // line-height: 20px
                     letterSpacing: 0, // letter-spacing: 0%
                     color: rule['color'],
                   ),
                 ),
                 SizedBox(height: 4.h),
                 // English Title
                 Text(
                   rule['englishTitle'],
                   style: TextStyle(
                     fontFamily: 'IBM Plex Sans Arabic',
                     fontWeight: FontWeight.w400, // Regular
                     fontSize: 13.sp,
                     height: 20 / 13, // line-height: 20px
                     letterSpacing: 0, // letter-spacing: 0%
                     color: rule['color'],
                   ),
                 ),
                 // English Subtitle
                 Text(
                   rule['englishSubtitle'],
                   style: TextStyle(
                     fontFamily: 'IBM Plex Sans Arabic',
                     fontWeight: FontWeight.w400, // Regular
                     fontSize: 13.sp,
                     height: 20 / 13, // line-height: 20px
                     letterSpacing: 0, // letter-spacing: 0%
                     color: rule['color'],
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
