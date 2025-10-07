
 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manara/presentation/views/Duaa/widget/duaa_mood_category_widget.dart';
import 'package:manara/presentation/views/Duaa/widget/duas_mood_screen.dart';
import 'package:manara/presentation/views/Duaa/widget/myDuaa_widget.dart';
import 'package:manara/presentation/views/Duaa/widget/my_duas_screen.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/dua/dua_categories_index.dart';
import '../../../data/models/dua/dua_category_model.dart';

import '../../widgets/dua_categories_shimmer_loader.dart';

class DuaaMainScreen extends StatelessWidget {
  const DuaaMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => DuaCategoriesBloc()..add(const LoadDuaCategories()),
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
            'Duas'.tr,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeights.semiBold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// My Duas
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      color: AppColors.colorPrimary,
                      size: 22.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'my_duas'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const Spacer(),
                    /// View all
                    IconButton(
                      onPressed: () => Get.to(const MyDuaaScreen()),
                      icon: Row(
                        children: [
                          Text(
                            'view_all'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.colorPrimary,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.colorPrimary,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12.h),
                DuaaCarouselSection(),
                SizedBox(height: 24.h),
                /// All Duas
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetsPath.duaaBookSvg,
                      width: 20.w,
                      height: 20.h,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'all_duas'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                BlocBuilder<DuaCategoriesBloc, DuaCategoriesState>(
                                    builder: (context, state) {
                    if (state is DuaCategoriesLoading) {
                      return const DuaCategoriesShimmerLoader();
                    } else if (state is DuaCategoriesLoaded) {
                       final categories = state.categories.map((duaCategory) {
                         return MoodCategory(
                           emoji: _getCategoryIcon(duaCategory),
                           title: _getLocalizedCategoryName(duaCategory),
                         );
                       }).toList();
                      
                       return Column(
                         children: [
                           MoodGridWidget(
                             categories: categories,
                             onTap: (category) {
                               // Find the corresponding dua category
                               final duaCategory = state.categories[categories.indexOf(category)];
                               Get.to(DuasMoodScreen(
                                 title: '${category.emoji} ${category.title}',
                                 categoryId: duaCategory.id,
                               ));
                               debugPrint("Selected: ${category.title} (ID: ${duaCategory.id})");
                             },
                           ),
                         ],
                       );
                    } else if (state is DuaCategoriesLoadedOffline) {
                       final categories = state.categories.map((duaCategory) {
                         return MoodCategory(
                           emoji: _getCategoryIcon(duaCategory),
                           title: _getLocalizedCategoryName(duaCategory),
                         );
                       }).toList();
                      
                       return Column(
                         children: [
                           // Offline indicator
                           Container(
                             margin: EdgeInsets.only(bottom: 16.h),
                             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                             decoration: BoxDecoration(
                               color: theme.colorScheme.primary.withValues(alpha: 0.1),
                               borderRadius: BorderRadius.circular(8.r),
                               border: Border.all(
                                 color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                 width: 1,
                               ),
                             ),
                             child: Row(
                               children: [
                                 Icon(
                                   Icons.wifi_off,
                                   size: 16.sp,
                                   color: theme.colorScheme.primary,
                                 ),
                                 SizedBox(width: 8.w),
                                 Expanded(
                                   child: Text(
                                     state.message,
                                     style: TextStyle(
                                       fontSize: 12.sp,
                                       color: theme.colorScheme.primary,
                                     ),
                                   ),
                                 ),
                                 TextButton(
                                   onPressed: () {
                                     context.read<DuaCategoriesBloc>().add(const LoadDuaCategories());
                                   },
                                   child: Text(
                                     'Refresh',
                                     style: TextStyle(
                                       fontSize: 12.sp,
                                       color: theme.colorScheme.primary,
                                       fontWeight: FontWeight.w600,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           // Categories grid
                           MoodGridWidget(
                             categories: categories,
                             onTap: (category) {
                               // Find the corresponding dua category
                               final duaCategory = state.categories[categories.indexOf(category)];
                               Get.to(DuasMoodScreen(
                                 title: '${category.emoji} ${category.title}',
                                 categoryId: duaCategory.id,
                               ));
                               debugPrint("Selected: ${category.title} (ID: ${duaCategory.id})");
                             },
                           ),
                         ],
                       );
                    } else if (state is DuaCategoriesOffline) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 64.sp,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No Internet Connection',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.w),
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<DuaCategoriesBloc>().add(const LoadDuaCategories());
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is DuaCategoriesFailure) {
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              'Error loading duas: ${state.error}',
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ElevatedButton(
                              onPressed: () {
                                context.read<DuaCategoriesBloc>().add(const LoadDuaCategories());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedCategoryName(DuaCategoryModel category) {
    // Get current locale from GetX
    final locale = Get.locale?.languageCode ?? 'en';
    return category.getCategoryName(locale);
  }

  String _getCategoryIcon(DuaCategoryModel category) {
    final title = category.categoryEnglish.toLowerCase();
    
    // Map categories to specific icons based on content
    if (title.contains('forgiveness') || title.contains('sin')) {
      return '🛐';
    } else if (title.contains('anxiety') || title.contains('worry')) {
      return '😌';
    } else if (title.contains('preservation') || title.contains('protection')) {
      return '🛡️';
    } else if (title.contains('affliction') || title.contains('sudden')) {
      return '⚡';
    } else if (title.contains('guidance') || title.contains('leaving')) {
      return '🏠';
    } else if (title.contains('sick') || title.contains('illness')) {
      return '🏥';
    } else if (title.contains('healthy') || title.contains('body')) {
      return '💪';
    } else if (title.contains('relief') || title.contains('distress') || title.contains('debt')) {
      return '💸';
    } else if (title.contains('family') || title.contains('blessed')) {
      return '👨‍👩‍👧‍👦';
    } else if (title.contains('success')) {
      return '🎯';
    } else if (title.contains('taqwa') || title.contains('piety')) {
      return '🕌';
    } else if (title.contains('knowledge') || title.contains('ilm')) {
      return '📚';
    } else if (title.contains('prophet') || title.contains('muhammad')) {
      return '☪️';
    } else {
      // Default icon for unmatched categories
      return '🙏';
    }
  }
}

// Keep the original mood categories as fallback
List<MoodCategory> get moodCategories => [
  MoodCategory(emoji: "😊", title: "happy".tr),
  MoodCategory(emoji: "😌", title: "grateful".tr),
  MoodCategory(emoji: "😭", title: "depressed".tr),
  MoodCategory(emoji: "😡", title: "angry".tr),
  MoodCategory(emoji: "😐", title: "anxious".tr),
  MoodCategory(emoji: "😠", title: "lazy".tr),
  MoodCategory(emoji: "😢", title: "lonely".tr),
  MoodCategory(emoji: "😵", title: "tired".tr),
  MoodCategory(emoji: "🤢", title: "suicidal".tr),
  MoodCategory(emoji: "😬", title: "nervous".tr),
  MoodCategory(emoji: "😥", title: "sad".tr),
  MoodCategory(emoji: "🙄", title: "jealous".tr),
];
