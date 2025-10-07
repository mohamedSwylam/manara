import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../constants/images.dart';

class BookDetailsBottomSheet extends StatelessWidget {
  final String bookName;
  final String bookNameArabic;
  final String bookDescription;

  const BookDetailsBottomSheet({
    super.key,
    required this.bookName,
    required this.bookNameArabic,
    required this.bookDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      height: 400.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Top Row with Book Image, Name, and Close Button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Image
                Container(
                  width: 70.w,
                  height: 110.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.book,
                      size: 40.sp,
                      color: const Color(0xFF8D1B3D),
                    ),
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Book Names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // English/Arabic name based on current locale
                      Text(
                        Get.locale?.languageCode == 'ar' ? bookNameArabic : bookName,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF755A3F),
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Arabic/English name based on current locale
                      Text(
                        Get.locale?.languageCode == 'ar' ? bookName : bookNameArabic,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Close Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          
          // Book Description
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: SingleChildScrollView(
                child: Text(
                  bookDescription,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13, // line-height: 20px / font-size: 13px
                    letterSpacing: 0,
                    color: Colors.black87,
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
