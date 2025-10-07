import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/images.dart';
import '../../../../data/bloc/book_details/book_details_state.dart';

class BookBookmarkItem extends StatelessWidget {
  final BookBookmark bookmark;
  final VoidCallback onDelete;

  const BookBookmarkItem({
    super.key,
    required this.bookmark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(bookmark.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: const BoxDecoration(
          color: Color(0x4ce33c3c),
        ),
        child: SvgPicture.asset(
          AssetsPath.basketSVG,
          height: 20.h,
        ),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Book Part SVG with Chapter Number
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AssetsPath.bookPartSVG,
                    width: 40.w,
                    height: 40.h,
                  ),
                  Text(
                    '${bookmark.chapterNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Chapter Name
            Expanded(
              child: Text(
                bookmark.chapterName,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 15, // line-height: 20px / font-size: 15px
                  letterSpacing: 0,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Page Numbers
            Text(
              '${bookmark.pageStart}-${bookmark.pageEnd}',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
