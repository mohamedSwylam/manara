import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/azkar/azkar_index.dart';
import '../../../data/models/azkar/azkar_category_model.dart';
import '../../../data/models/azkar/azkar_tracking_model.dart';
import 'tasbeh_counter_screen.dart';

class TasbehScreen extends StatefulWidget {
  const TasbehScreen({super.key});

  @override
  State<TasbehScreen> createState() => _TasbehScreenState();
}

class _TasbehScreenState extends State<TasbehScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    
    return BlocProvider(
      create: (context) => AzkarBloc()..add(LoadAzkarData()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.iconTheme.color,
              size: 24.sp,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Tasbeh',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeights.semiBold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AzkarBloc, AzkarState>(
          builder: (context, state) {
            if (state is AzkarLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AzkarLoaded) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildRoutineCard(
                      context: context,
                      theme: theme,
                      icon: AssetsPath.favouritesSVG,
                      title: 'Favourites',
                      completed: 0,
                      total: 21,
                    ),
                    SizedBox(height: 8.h),
                                         _buildRoutineCard(
                       context: context,
                       theme: theme,
                       icon: AssetsPath.morningSVG,
                       title: 'Morning Routine',
                       completed: _getCompletedCount(state, 'Morning Adhkar'),
                       total: _getTotalCount(state, 'Morning Adhkar'),
                       categoryId: _getCategoryId(state, 'Morning Adhkar'),
                     ),
                    SizedBox(height: 8.h),
                                         _buildRoutineCard(
                       context: context,
                       theme: theme,
                       icon: AssetsPath.nightSVG,
                       title: 'Evening Routine',
                       completed: _getCompletedCount(state, 'Evening Adhkar'),
                       total: _getTotalCount(state, 'Evening Adhkar'),
                       categoryId: _getCategoryId(state, 'Evening Adhkar'),
                     ),
                    SizedBox(height: 8.h),
                                         _buildRoutineCard(
                       context: context,
                       theme: theme,
                       icon: AssetsPath.sleepSVG,
                       title: 'Before Sleeping Routine',
                       completed: _getCompletedCount(state, 'Before Sleep'),
                       total: _getTotalCount(state, 'Before Sleep'),
                       categoryId: _getCategoryId(state, 'Before Sleep'),
                     ),
                    SizedBox(height: 8.h),
                                         _buildRoutineCard(
                       context: context,
                       theme: theme,
                       icon: AssetsPath.wakeUpSVG,
                       title: 'Waking Up Routine',
                       completed: _getCompletedCount(state, 'Salah'),
                       total: _getTotalCount(state, 'Salah'),
                       categoryId: _getCategoryId(state, 'Salah'),
                     ),
                    SizedBox(height: 8.h),
                                         _buildRoutineCard(
                       context: context,
                       theme: theme,
                       icon: AssetsPath.sjagahSVG,
                       title: 'After Prayer Routine',
                       completed: _getCompletedCount(state, 'After Salah'),
                       total: _getTotalCount(state, 'After Salah'),
                       categoryId: _getCategoryId(state, 'After Salah'),
                     ),
                    SizedBox(height: 8.h),
                                         _buildRoutineCard(
                       context: context,
                       theme: theme,
                       icon: AssetsPath.healthSVG,
                       title: 'Health Routine',
                       completed: _getCompletedCount(state, 'Ruqyah & Illness'),
                       total: _getTotalCount(state, 'Ruqyah & Illness'),
                       categoryId: _getCategoryId(state, 'Ruqyah & Illness'),
                     ),
                  ],
                ),
              );
            } else if (state is AzkarFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading azkar: ${state.error}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AzkarBloc>().add(LoadAzkarData());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('No data available'),
              );
            }
          },
        ),
      ),
    );
  }

  // Helper methods to get data from azkar state
  int _getCompletedCount(AzkarLoaded state, String categoryName) {
    // Map English category names to Arabic names from API
    final arabicCategoryName = _getArabicCategoryName(categoryName);
    final tracking = state.getTrackingForCategory(arabicCategoryName);
    return tracking?.done ?? 0;
  }

  int _getTotalCount(AzkarLoaded state, String categoryName) {
    // Map English category names to Arabic names from API
    final arabicCategoryName = _getArabicCategoryName(categoryName);
    final tracking = state.getTrackingForCategory(arabicCategoryName);
    return tracking?.total ?? 0;
  }

  String? _getCategoryId(AzkarLoaded state, String categoryName) {
    // Map English category names to Arabic names from API
    final arabicCategoryName = _getArabicCategoryName(categoryName);
    print('🔍 Looking for category: $categoryName -> $arabicCategoryName');
    print('📋 Available categories: ${state.categories.map((c) => '${c.categoryArabic} (${c.id})').join(', ')}');
    
    final category = state.categories.firstWhere(
      (cat) => cat.categoryArabic == arabicCategoryName,
      orElse: () {
        print('⚠️ Category not found, using first category: ${state.categories.first.categoryArabic} (${state.categories.first.id})');
        return state.categories.first;
      },
    );
    print('✅ Selected category: ${category.categoryArabic} (${category.id})');
    return category.id;
  }

  // Map English category names to Arabic names from API response
  String _getArabicCategoryName(String englishName) {
    switch (englishName) {
      case 'Morning Adhkar':
        return 'صلاة الفجر';
      case 'Evening Adhkar':
        return 'صلاة العشاء';
      case 'Before Sleep':
        return 'قبل النوم';
      case 'Salah':
        return 'صلاح';
      case 'After Salah':
        return 'بعد الصلاة';
      case 'Ruqyah & Illness':
        return 'الرقية والمرض';
      case 'Praises of Allah':
        return 'الحمد لله';
      case 'Istighfar':
        return 'استغفار';
      default:
        return englishName; // Fallback to original name
    }
  }

  Widget _buildRoutineCard({
    required BuildContext context,
    required ThemeData theme,
    required String icon,
    required String title,
    required int completed,
    required int total,
    String? categoryId,
  }) {
    // Get the appropriate color for each routine
    Color getIconColor() {
      final isDark = theme.brightness == Brightness.dark;
      
      switch (title.toLowerCase()) {
        case 'favourites':
          return const Color(0xFF8D1B3D); // Maroon for Favourites
        case 'morning routine':
          return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F1F1);
        case 'evening routine':
          return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F1F1);
        case 'before sleeping routine':
          return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F1F1);
        case 'waking up routine':
          return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F1F1);
        case 'after prayer routine':
          return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F1F1);
        case 'health routine':
          return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F1F1);
        default:
          return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F1F1);
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TasbehCounterScreen(
              routineName: title,
              totalCount: total,
              categoryId: categoryId,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: getIconColor(),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 24.w,
                  height: 24.h,
                  colorFilter: title.toLowerCase() == 'favourites'
                      ? const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  )
                  : null,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeights.semiBold,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$completed/$total Completed Today',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeights.regular,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
