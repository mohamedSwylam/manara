import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/Providers/wallpaper_provider.dart';

class SetWallPaper extends StatefulWidget {
  const SetWallPaper({super.key, required this.index});
  final int index;
  @override
  State<SetWallPaper> createState() => _SetWallPaperState();
}

class _SetWallPaperState extends State<SetWallPaper> {

  // ignore: prefer_final_fields
  double? _containerHeight = 115.0,
      _containerWidth;
  bool? showInfo = false,
      isLongPress = false;

  Icon sizeChangeIcon = const Icon(
    Icons.fullscreen_exit,
    color: AppColors.colorWhiteHighEmp,
  );
  BoxFit imageFit = BoxFit.cover;
  bool isFitCover = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<WallPaperProvider>(
      builder: (context, provider, child){
        return Scaffold(
          backgroundColor: AppColors.colorBlack,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            toolbarOpacity: (isLongPress!) ? 0.0 : 1.0,
            backgroundColor: Colors.transparent,
            titleSpacing: 0,
            title: Text(
              'wallpaper'.tr,
              style: TextStyle(
                color:
                  (isLongPress!)
                      ? Colors.transparent
                      : AppColors.colorWhiteHighEmp,
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isLongPress!)
                        ? Colors.transparent
                        : Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            elevation: 0.0,
            iconTheme: const IconThemeData(color: AppColors.colorWhiteHighEmp),
            actions: [
              IconButton(
                icon: sizeChangeIcon,
                onPressed: () {
                  setState(() {
                    isFitCover = !isFitCover;
                    imageFit = (isFitCover) ? BoxFit.cover : BoxFit.contain;
                    sizeChangeIcon = (isFitCover)
                        ? const Icon(
                      Icons.fullscreen_exit,
                      color: AppColors.colorWhiteHighEmp,
                    )
                        : const Icon(
                      Icons.fullscreen,
                      color: AppColors.colorWhiteHighEmp,
                    );
                  },
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              GestureDetector(
                onLongPressStart: (value) {
                  setState(() {
                    isLongPress = true;
                  });
                },
                onLongPressEnd: (value) {
                  setState(() {
                    isLongPress = false;
                  });
                },
                child: Image.network(
                  provider.allWallpapers![widget.index].originalUrl,
                  loadingBuilder: (BuildContext? context, Widget? child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child!;
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(provider.allWallpapers![widget.index].thumbnailUrl), fit: BoxFit.cover),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Text(
                                'press_&_hold_for_preview'.tr,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: AppColors.colorWhiteHighEmp,
                                  backgroundColor: AppColors.colorBlack,
                                ),
                              ),
                              SizedBox(height: 50.h),
                              CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.colorWhiteHighEmp),
                                strokeWidth: 2.0,
                                backgroundColor: AppColors.colorBlack,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  fit: imageFit,
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 50.0),
                  child: buildPhotoActions(context, provider.allWallpapers![widget.index].originalUrl),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPhotoActions(BuildContext context, largeImage) {
    bool android;
    if (Theme.of(context).platform == TargetPlatform.android) {
      android = true;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      android = false;
    } else {
      android = false; // Default color for unknown platform
    }
    String? result;
    // ignore: prefer_typing_uninitialized_variables
    var file;
    final provider = Provider.of<WallPaperProvider>(context, listen: false);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(
          0, (isLongPress!) ? (_containerHeight! + 150.0) : 0, 0),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: AppColors.colorBlack,
            blurRadius: 10.0,
          ),
        ],
        borderRadius: BorderRadius.circular(50.0),
        color: AppColors.colorPrimaryLighter,
      ),
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(10.h),
      width: _containerWidth,
      height: MediaQuery
          .of(context)
          .size
          .height * 0.1,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            android?
            GestureDetector(
              onTap: (){
                _save(provider.allWallpapers![widget.index].originalUrl);
              },
              child: Icon(
                Icons.save_alt,
                size: 24.sp,
                color: AppColors.colorWhiteHighEmp,
              )
            ) : const SizedBox(),
            android?
            GestureDetector(
              onTap: () async{
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'setting_both_screen'.tr,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                file = await DefaultCacheManager().getSingleFile(largeImage);
                result = await WallpaperManagerPlus().setWallpaper(
                    file.path, WallpaperManagerPlus.bothScreens)
                // ignore: missing_return
                    .then((value) {
                  Fluttertoast.showToast(
                    msg: 'successfully_set_wallpaper'.tr,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  return null;
                });
              },
              child: Image.asset(
                  AssetsPath.wallpaper2,
                height: 50.h,
                width: 50.h,
              ),
            ) : GestureDetector(
                onTap: (){
                  _save(provider.allWallpapers![widget.index].originalUrl);
                },
                child: Icon(
                  Icons.save_alt,
                  size: 24.sp,
                  color: AppColors.colorWhiteHighEmp,
                )
            ),
            android?
            GestureDetector(
              onTap: (){
                handleApply(provider.allWallpapers![widget.index].originalUrl, context);
              },
              child: Icon(
                  Icons.more_horiz,
                color: AppColors.colorWhiteHighEmp,
                size: 24.sp,
              ),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }


  // ignore: prefer_void_to_null
  Future<Null> handleApply(String image, BuildContext context) async {
    String? result;
    // ignore: prefer_typing_uninitialized_variables
    var file;

    try {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 300.h,
            child: Padding(
              padding:
               EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 40.h),
                  Text(
                    'what_would_like_to_do'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeights.bold,
                      color: AppColors.colorBlack,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      Image.asset(
                        AssetsPath.phone,
                        height: 20.h,
                        width: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: () async{
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                            msg: 'setting_home_screen'.tr,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          file = await DefaultCacheManager().getSingleFile(image);
                          result = await WallpaperManagerPlus().setWallpaper(
                              file.path, WallpaperManagerPlus.homeScreen)
                          // ignore: missing_return
                              .then((value) {
                            Fluttertoast.showToast(
                              msg: "successfully_set_wallpaper".tr,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return null;
                          });
                        },
                        child: Text(
                          'set_on_home_screen'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeights.regular,
                            color: AppColors.colorBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(height: 1),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Image.asset(
                        AssetsPath.lockPhone,
                        height: 20.h,
                        width: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: () async{
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                            msg: 'setting_lock_screen'.tr,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          file = await DefaultCacheManager().getSingleFile(image);
                          result = await WallpaperManagerPlus().setWallpaper(
                              file.path, WallpaperManagerPlus.lockScreen)
                          // ignore: missing_return
                              .then((value) {
                            Fluttertoast.showToast(
                              msg: 'successfully_set_wallpaper'.tr,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return null;
                          });
                        },
                        child: Text(
                          'set_on_lock_screen'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeights.regular,
                            color: AppColors.colorBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(height: 1),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Image.asset(
                        AssetsPath.lockPhone2,
                        height: 20.h,
                        width: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: () async{
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                            msg: 'setting_home_screen'.tr,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          file = await DefaultCacheManager().getSingleFile(image);
                          result = await WallpaperManagerPlus().setWallpaper(
                              file.path, WallpaperManagerPlus.bothScreens)
                          // ignore: missing_return
                              .then((value) {
                            Fluttertoast.showToast(
                              msg: 'successfully_set_wallpaper'.tr,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return null;
                          });
                        },
                        child: Text(
                          'set_on_both_screen'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeights.regular,
                            color: AppColors.colorBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(height: 1),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Image.asset(
                        AssetsPath.save,
                        height: 24.h,
                        width: 24.w,
                      ),
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: () {
                          _save(Provider.of<WallPaperProvider>(context, listen: false).allWallpapers![widget.index].originalUrl);
                          Navigator.pop(
                              context);
                        },
                        child: Text(
                          'save_to_device'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeights.regular,
                            color: AppColors.colorBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } on PlatformException {
      result = 'failed_to_get_wallpaper'.tr;
    }
  }

  Future<void> _save(String image) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          backgroundColor: AppColors.colorPrimary,
          content: Text('saving_image'.tr),
        ),
      );
    }

    TextStyle _selectedStyle = TextStyle(
      color: AppColors.colorWhiteHighEmp,
      // Set any other style properties as per your design requirements
    );

    var status = await Permission.storage.request();
    if(status.isGranted){
      var response = await Dio().get(
          image,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaverPlus.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "image");
      print(result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            backgroundColor: AppColors.colorPrimary,
            content: Text('image_saved_successfully'.tr),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }


}
