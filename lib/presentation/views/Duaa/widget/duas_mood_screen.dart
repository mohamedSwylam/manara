import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../constants/fonts_weights.dart';
import '../../../../data/bloc/dua/dua_list_index.dart';
import '../../../../data/bloc/favorites/favorites_index.dart';
import '../../../../data/models/dua/dua_model.dart';
import '../../../widgets/dua_shimmer_loader.dart';
import 'duaa_card_widget.dart';

class DuasMoodScreen extends StatelessWidget {
  final String title;
  final String? categoryId;

  const DuasMoodScreen({
    super.key, 
    required this.title,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            if (categoryId != null) {
              return DuaListBloc()..add(LoadDuasByCategory(categoryId!));
            }
            return DuaListBloc();
          },
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(),
        ),
      ],
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
            title,
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
          child: BlocBuilder<DuaListBloc, DuaListState>(
                         builder: (context, state) {
               if (state is DuaListLoading) {
                 return const DuaShimmerLoader();
               } else if (state is DuaListLoaded) {
                if (state.duas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64.sp,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'no_duas_found'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                 return BlocListener<FavoritesBloc, FavoritesState>(
                   listener: (context, favoritesState) {
                     if (favoritesState is FavoritesFailure) {
                       // Show snackbar for failure
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text(favoritesState.error),
                           backgroundColor: Colors.red,
                           duration: const Duration(seconds: 3),
                         ),
                       );
                     }
                   },
                   child: BlocBuilder<FavoritesBloc, FavoritesState>(
                     builder: (context, favoritesState) {
                       // Load favorite status when duas are loaded
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                         final duaIds = state.duas.map((dua) => dua.id).toList();
                         context.read<FavoritesBloc>().add(LoadFavoriteStatus(duaIds));
                       });
                       
                       return ListView.separated(
                         itemCount: state.duas.length,
                         separatorBuilder: (context, index) => SizedBox(height: 16.h),
                         itemBuilder: (context, index) {
                           final dua = state.duas[index];
                           final locale = Get.locale?.languageCode ?? 'en';
                           final isFavorite = favoritesState is FavoritesLoaded 
                               ? favoritesState.isDuaFavorited(dua.id)
                               : false;
                           
                           return SizedBox(
                             height: 260.h,
                             child: DuaaCardWidget(
                               title: dua.getTitle(locale),
                               arabicText: dua.getDuaText(locale),
                               englishText: dua.duaEnglish, // Always show English as translation
                               isFavorite: isFavorite,
                               onFavoriteToggle: () {
                                 context.read<FavoritesBloc>().add(ToggleDuaFavorite(dua.id));
                               },
                             ),
                           );
                         },
                       );
                     },
                   ),
                 );
              } else if (state is DuaListFailure) {
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
                        'Error loading duas: ${state.error}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          if (categoryId != null) {
                            context.read<DuaListBloc>().add(LoadDuasByCategory(categoryId!));
                          }
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
      ),
    );
  }
}
