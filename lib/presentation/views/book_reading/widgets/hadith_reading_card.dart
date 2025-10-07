import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../book_reading_screen.dart';

class HadithReadingCard extends StatelessWidget {
  final HadithReadingData hadith;

  const HadithReadingCard({
    super.key,
    required this.hadith,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328.w,
      constraints: BoxConstraints(
        minHeight: 120.h, // Minimum height
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Chapter and Hadith Number
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '(${hadith.chapterNumber}.${hadith.hadithNumber})',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  hadith.chapterTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Narrator
            Text(
              hadith.narrator,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF755A3F),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Arabic Text
            Text(
              hadith.arabicText,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // English Text
            Text(
              hadith.englishText,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
            
            SizedBox(height: 8.h),
            
                         // Explanation (truncated if too long)
             Text(
               hadith.explanation,
               style: GoogleFonts.poppins(
                 fontSize: 11.sp,
                 fontWeight: FontWeight.w400,
                 color: Colors.black54,
                 height: 1.2,
               ),
               overflow: TextOverflow.ellipsis,
               maxLines: 3,
             ),
          ],
        ),
      ),
    );
  }
}
