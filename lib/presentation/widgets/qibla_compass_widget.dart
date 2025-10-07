import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constants/images.dart';
import '../../data/bloc/qibla_bloc.dart';
import '../../data/models/qibla_events.dart';
import '../../data/models/qibla_state.dart';
import '../../data/viewmodel/Providers/location_provider.dart';

class QiblaCompassWidget extends StatefulWidget {
  final AnimationController? animationController;
  final double begin;

  const QiblaCompassWidget({
    Key? key,
    required this.animationController,
    required this.begin,
  }) : super(key: key);

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget> {
  Animation<double>? animation;
  double currentAngle = 0.0;
  double targetAngle = 0.0;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation
    animation = Tween(
      begin: 0.0,
      end: 0.0,
    ).animate(widget.animationController!);
  }

  void _updateAnimation(double newQiblahAngle) {
    if (widget.animationController == null) return;

    double newTargetAngle = (newQiblahAngle * (pi / 180));

    // Only update if the target angle has changed significantly (reduced threshold for more responsiveness)
    if ((newTargetAngle - targetAngle).abs() > 0.05) {
      currentAngle = targetAngle;
      targetAngle = newTargetAngle;

      // Create new animation with faster, more responsive curve
      animation = Tween(
        begin: currentAngle,
        end: targetAngle,
      ).animate(CurvedAnimation(
        parent: widget.animationController!,
        curve: Curves.linear, // Use linear for immediate response
      ));

      // Start animation with shorter duration for more responsiveness
      widget.animationController!.duration = const Duration(milliseconds: 200);
      widget.animationController!.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            child: Center(
              child: CircularProgressIndicator(
                color: theme.scaffoldBackgroundColor,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 12.sp,
              ),
            ),
          );
        } else if (snapshot.hasData) {
          // Check if snapshot has data
          final qiblahDirection = snapshot.data;

          // Update BLoC with device direction data
          // The plugin provides current compass heading (direction) and relative qiblah.
          // We pass them through so BLoC can compute facing logic; UI rotation uses qiblah.
          context.read<QiblaBloc>().add(UpdateDeviceDirection(
                direction: qiblahDirection!.direction,
                qiblah: qiblahDirection.qiblah,
              ));

          // Update animation with new qiblah angle
          _updateAnimation(qiblahDirection.qiblah);

          return BlocBuilder<QiblaBloc, QiblaState>(
            builder: (context, state) {
              return Center(
                child: Consumer<LocationProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ///Compass
                        SizedBox(
                          height: 15.h,
                        ),
                        Center(
                          child: SizedBox(
                            height: 15.h,
                            width: 18.w,
                            child: SvgPicture.asset(
                              AssetsPath.polygon,
                              fit: BoxFit.fill,
                              colorFilter: isDark
                                  ? ColorFilter.mode(
                                      Colors.grey[400]!, BlendMode.srcIn)
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                height: 240.h,
                                width: 240.w,
                                child: SvgPicture.asset(
                                  AssetsPath.compassBg,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                height: 240.h,
                                child: AnimatedBuilder(
                                  animation: animation!,
                                  builder: (context, child) => Transform.rotate(
                                    angle: animation!.value,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          state.isFacingQiblah
                                              ? Image.asset(
                                                  AssetsPath.makkaENBPNG,
                                                  height: 40.h)
                                              : Image.asset(
                                                  AssetsPath.makkaDISPNG,
                                                  height: 40.h),
                                          ColorFiltered(
                                            colorFilter: isDark
                                                ? const ColorFilter.mode(
                                                    Color(0xFF916B46),
                                                    BlendMode.srcIn)
                                                : const ColorFilter.mode(
                                                    Colors.black,
                                                    BlendMode.srcIn),
                                            child: Image.asset(
                                                AssetsPath.arrowgbt,
                                                height: 105.h),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        ///text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon based on state
                            Icon(
                              state.isFacingQiblah
                                  ? Icons.check_circle // Right direction icon
                                  : !state.isPhoneLyingFlat
                                      ? Icons
                                          .screen_rotation // Flip phone icon when not lying flat
                                      : Icons.rotate_right, // Rotate icon
                              color: state.isFacingQiblah
                                  ? Colors.green
                                  : theme.textTheme.bodySmall?.color ??
                                      const Color(0xFF828282),
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            // Text based on state
                            Flexible(
                              child: Text(
                                state.isFacingQiblah
                                    ? "you_are_now_facing_mecca".tr
                                    : !state.isPhoneLyingFlat
                                        ? "please_lay_your_phone_flat".tr
                                        : "${"rotate_your_phone".tr} ${state.qiblahAngle?.abs().toInt() ?? 0}° ${(state.qiblahAngle ?? 0) > 0 ? 'left'.tr : 'right'.tr}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color ??
                                      const Color(0xFF828282),
                                  fontSize: 15.sp,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w400,
                                  height: 20 /
                                      15, // line-height: 20px / font-size: 15px
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        } else {
          // Handle no data scenario
          return Center(
            child: Text(
              'unble_to_get_qible'.tr,
              style: TextStyle(color: theme.scaffoldBackgroundColor),
            ),
          );
        }
      },
    );
  }
}
