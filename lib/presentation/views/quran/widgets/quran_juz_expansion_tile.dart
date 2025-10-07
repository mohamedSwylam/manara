import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../constants/images.dart';
import '../../../../data/bloc/quran/quran_state.dart';
import '../../../../data/services/quran_api_service.dart';
import '../../al_quran_details_screen.dart';

class QuranJuzCard extends StatelessWidget {
  final QuranJuz juz;
  final VoidCallback? onTap;

  const QuranJuzCard({
    super.key,
    required this.juz,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Juz header
        Container(
          color: theme.cardTheme.color?.withOpacity(0.5) ?? const Color(0x66FFFFFF),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Juz\' ${juz.number}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8D1B3D),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Quarters list
        ...juz.quarters.map((quarter) => _buildQuarterItem(context, quarter)),
      ],
    );
  }

    Widget _buildQuarterItem(BuildContext context, QuranQuarter quarter) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        // Navigate to specific quarter
        Get.to(() => AlQuranScreen(
          surahName: quarter.surahName,
          surahNumber: quarter.surahNumber,
        ));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: theme.cardTheme.color,
        child: Row(
          children: [
            // Quarter number in small circle
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  AssetsPath.bookPartSVG,
                  width: 40.w,
                  height: 40.h,
                ),
                Text(
                  quarter.quarterName,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:  Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),

            // Quarter details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quarter name with surah
                  Text(
                    '${quarter.surahName} - Aya ${quarter.startAyah}',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Starting ayah text
                  FutureBuilder<String>(
                    future: _getAyahText(quarter.surahNumber, quarter.startAyah),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Loading...',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error loading text',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                          ),
                        );
                      } else {
                        final text = snapshot.data ?? 'Ayah text not available';
                        // Truncate text to one line with ellipsis
                        final truncatedText = text.length > 80 ? '${text.substring(0, 80)}...' : text;
                        return Text(
                          truncatedText,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                    },
                  ),

                  SizedBox(height: 4.h),

                  // Page number
                  Text(
                    'Page ${quarter.pageNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8D1B3D),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 12.sp,
              color: theme.textTheme.bodySmall?.color ?? Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getAyahText(int surahNumber, int ayahNumber) async {
    try {
      // Use the real API to fetch ayah text
      return await QuranApiService.getAyahText(surahNumber, ayahNumber);
    } catch (e) {
      print('Error getting ayah text: $e');
      return 'Ayah text not available';
    }
  }
}
