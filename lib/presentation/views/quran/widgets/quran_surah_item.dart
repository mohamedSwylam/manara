import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../constants/images.dart';
import '../../../../data/bloc/quran/quran_state.dart';

class QuranSurahItem extends StatelessWidget {
  final QuranSurah surah;
  final VoidCallback onTap;

  const QuranSurahItem({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            color: theme.cardTheme.color,
            child: Row(
              children: [
                // Surah number without circle border
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      AssetsPath.bookPartSVG,
                      width: 40.w,
                      height: 40.h,
                    ),
                    Text(
                      '${surah.number}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8D1B3D),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                // Surah details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // English name with number
                      Row(
                        children: [
                          // Show English name only if app is in English mode
                          if (Get.locale?.languageCode == 'en' && surah.englishName.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child:                               Text(
                                surah.englishName,
                                style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                              ),
                              ),
                            ),
                          SizedBox(height: 4.h),
                          Text(
                            ' ${surah.name}',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),
                      // Revelation type, ayahs, and juz
                       Row(
                         children: [
                           // Revelation type text
                           Text(
                             surah.revelationType,
                             style: GoogleFonts.poppins(
                               fontSize: 10.sp,
                               fontWeight: FontWeight.w500,
                               color: const Color(0xFFA7805A)
                             ),
                           ),
                           
                           SizedBox(width: 8.w),
                           
                           // Number of ayahs
                           Text(
                             '- ${surah.numberOfAyahs} Ayahs',
                             style: GoogleFonts.poppins(
                               fontSize: 10.sp,
                               fontWeight: FontWeight.w400,
                               color: const Color(0xFFA7805A)
                             ),
                           ),
                           
                           SizedBox(width: 8.w),
                           
                           // Juz information
                           Container(
                             padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                             decoration: BoxDecoration(
                               color: const Color(0xFF8D1B3D).withOpacity(0.1),
                               borderRadius: BorderRadius.circular(4.r),
                             ),
                             child: Text(
                               'Juz ${surah.juz}',
                               style: GoogleFonts.poppins(
                                 fontSize: 9.sp,
                                 fontWeight: FontWeight.w600,
                                 color: const Color(0xFF8D1B3D)
                               ),
                             ),
                           ),
                         ],
                       ),
                    ],
                  ),
                ),
                
                // Page number
                Text(
                  '${surah.page}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color ?? const Color(0xFF828282)
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Divider
        Divider(
          height: 1,
          thickness: 0.5,
          color: theme.dividerTheme.color ?? Colors.grey.shade200,
          indent: 68.w, // Align with content (40 + 12 + 16)
        ),
      ],
    );
  }
}
