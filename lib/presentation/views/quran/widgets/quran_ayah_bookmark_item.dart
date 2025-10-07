import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/quran/quran_ayah_bookmark_model.dart';

class QuranAyahBookmarkItem extends StatelessWidget {
  final QuranAyahBookmarkModel bookmark;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const QuranAyahBookmarkItem({
    super.key,
    required this.bookmark,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(bookmark.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Bookmark icon
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: bookmark.type == BookmarkType.ayah 
                      ? const Color(0xFFE8F5E8)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: bookmark.type == BookmarkType.ayah 
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFFD54F),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    bookmark.type == BookmarkType.ayah 
                        ? Icons.text_snippet
                        : Icons.bookmark,
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
                    // Surah name and type
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bookmark.surahName,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: bookmark.type == BookmarkType.ayah 
                                ? const Color(0xFF4CAF50).withOpacity(0.1)
                                : const Color(0xFFFFD54F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            bookmark.type == BookmarkType.ayah ? 'Ayah' : 'Page',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: bookmark.type == BookmarkType.ayah 
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFFD54F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Ayah number or page info
                    if (bookmark.type == BookmarkType.ayah) ...[
                      Text(
                        'Ayah ${bookmark.ayahNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8D1B3D),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        bookmark.ayahText.length > 50 
                            ? '${bookmark.ayahText.substring(0, 50)}...'
                            : bookmark.ayahText,
                        style: GoogleFonts.amiri(
                          fontSize: 12.sp,
                          color: Colors.black54,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ] else ...[
                      Text(
                        'Page ${bookmark.pageNumber} - Juz ${bookmark.juzNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8D1B3D),
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 2.h),
                    
                    // Date
                    Text(
                      'Bookmarked on ${_formatDate(bookmark.createdAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
