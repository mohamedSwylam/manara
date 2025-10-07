import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/bloc/quran/quran_state.dart';

class QuranBookmarkItem extends StatelessWidget {
  final QuranBookmark bookmark;
  final VoidCallback onDelete;

  const QuranBookmarkItem({
    super.key,
    required this.bookmark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bookmark icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD54F),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.bookmark,
                size: 20.sp,
                color: const Color(0xFF8D1B3D),
              ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Bookmark details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Surah name
                Text(
                  bookmark.surahName,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                  ),
                ),
                
                SizedBox(height: 4.h),
                
                // Page and Juz info
                Text(
                  'Page ${bookmark.pageNumber} - Juz ${bookmark.juzNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8D1B3D),
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                // Date
                Text(
                  'Bookmarked on ${_formatDate(bookmark.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.textTheme.bodySmall?.color ?? Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: 20.sp,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
