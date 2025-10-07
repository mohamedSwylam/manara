import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoodGridWidget extends StatelessWidget {
  final List<MoodCategory> categories;
  final void Function(MoodCategory)? onTap;

  const MoodGridWidget({
    Key? key,
    required this.categories,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 105.33 / 68, // Match the specified dimensions
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => onTap?.call(category),
          child: Container(
            width: 105.33.w,
            padding: EdgeInsets.fromLTRB(2.w, 8.h, 6.w, 8.h), // Reduced padding to fit content
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(8.r), // 8px border radius
              border: Border.all(
                color: const Color(0xFFE0E0E0), // #E0E0E0 border color
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                Text(
                  category.emoji,
                  style: TextStyle(fontSize: 16.sp), // Reduced font size
                ),
                SizedBox(height: 2.h), // Reduced spacing
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 10.sp, // Reduced font size
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MoodCategory {
  final String emoji;
  final String title;

  MoodCategory({required this.emoji, required this.title});
}
