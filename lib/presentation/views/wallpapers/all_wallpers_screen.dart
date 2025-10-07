import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:manara/presentation/views/wallpapers/set_wallpaper_screen.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/Providers/wallpaper_provider.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/custom_appbar_widget.dart';

class AllWallPapersScreen extends StatefulWidget {
  const AllWallPapersScreen({super.key});

  @override
  State<AllWallPapersScreen> createState() => _AllWallPapersScreenState();
}

class _AllWallPapersScreenState extends State<AllWallPapersScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        // backgroundColor: AppColors.colorError ,
        body: Stack(
      children: [
        AppBackgroundImageWidget(bgImagePath: AssetsPath.secondaryBGSVG),
        Column(
          children: [
            CustomAppbarWidget(
              screenTitle: "wallpaper".tr,
            ),
            Expanded(
              child: Consumer<WallPaperProvider>(
                builder: (context, provider, child) {
                  if (provider.allWallpapers!.isEmpty) {
                    return Center(
                      child: Text(
                        "No Wallpaper found!",
                        style: TextStyle(
                            color: theme.textTheme.titleLarge?.color ?? AppColors.colorWhiteHighEmp, fontSize: 20),
                      ),
                    );
                  } else {
                    return GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of items horizontally
                        crossAxisSpacing:
                            12.0, // Spacing between items horizontally
                        mainAxisSpacing:
                            12.0, // Spacing between items vertically
                        childAspectRatio: 0.8,
                      ),
                      itemCount: provider.allWallpapers!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SetWallPaper(
                                  index: index,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.colorPrimaryLight,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  provider.allWallpapers![index].thumbnailUrl,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        )
      ],
    ));
  }
}
