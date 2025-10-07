import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/images.dart';
import '../../../../data/bloc/hadith/hadith_state.dart';

class BookmarkItem extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onDelete;

  const BookmarkItem({
    super.key,
    required this.bookmark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bookmark Title
                  Text(
                    bookmark.lessonName,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Lesson Number
                  Text(
                    '${bookmark.lessonName}: ${bookmark.lessonNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffA7805A),
                    ),
                  ),
                ],
              ),
            ),
            
            // Chapter Number
            Text(
              '${bookmark.chapterNumber}',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
