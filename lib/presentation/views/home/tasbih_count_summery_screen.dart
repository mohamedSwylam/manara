import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../constants/images.dart';
import '../../../constants/colors.dart';
import '../../../data/viewmodel/Providers/counter_provider.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/custom_appbar_widget.dart';
import '../bar_graph/bar_graph.dart';

class TasbihCountSummaryScreen extends StatefulWidget {
  const TasbihCountSummaryScreen({Key? key}) : super(key: key);

  @override
  State<TasbihCountSummaryScreen> createState() =>
      _TasbihCountSummaryScreenState();
}

class _TasbihCountSummaryScreenState extends State<TasbihCountSummaryScreen> {
  final PageController _pageController = PageController(initialPage: 1);

  List<String> leftNumbers = ['1000', '800', '600', '400', '200', '0'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImageWidget(
            bgImagePath: AssetsPath.secondaryBGSVG,
          ),
          CustomAppbarWidget(
            screenTitle: 'counter_summery'.tr,
          ),
          Column(
            children: [
              SizedBox(height: 120.h),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(left: 24.h, right: 24.h),
                  child: Container(
                    height: 340.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.colorGradient1Start,
                          AppColors.colorGradient1End
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('yyyy/MM/dd').format(DateTime.now()),
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.colorWhiteHighEmp),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.linear_scale,
                                color: AppColors.colorWhiteHighEmp,
                                size: 10,
                              ),
                            ),
                            Text(
                              DateFormat('yyyy/MM/dd').format(DateTime.now()),
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.colorWhiteHighEmp),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 130.h,
                              width: 40.w,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: leftNumbers.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    height: 22.h,
                                    child: Text(
                                      leftNumbers[index],
                                      style: TextStyle(
                                          color: AppColors.colorWhiteHighEmp,
                                          fontSize: 12.sp),
                                    ),
                                  );
                                },
                              ),
                            ),
                            FutureBuilder<List<int>>(
                              future: ZikirProvider().getLast7DaysTotalCounts(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final last7DaysTotalCounts = snapshot.data!;
                                  //final weeklySummary = last7DaysTotalCounts?.map((count) => count.toDouble()).toList();
                                  return SizedBox(
                                      height: 130.h,
                                      width: 200.w,
                                      child: BarGraph(
                                        weeklySummary: last7DaysTotalCounts
                                            .map((count) => count != null
                                                ? (count > 1000
                                                    ? 1000.0
                                                    : count.toDouble())
                                                : 0.0)
                                            .toList(),
                                      ));
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                       Padding(
                                        padding: EdgeInsets.all(4.h),
                                        child: const Icon(
                                          Icons.access_time,
                                          color: AppColors.colorWhiteHighEmp,
                                        ),
                                      ),
                                      Text(
                                        'total_count'.tr,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: AppColors.colorWhiteHighEmp,
                                        ),
                                      )
                                    ],
                                  ),
                                  FutureBuilder<int>(
                                    future: Provider.of<ZikirProvider>(context)
                                        .getTotalCountLast7Days(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else {
                                        int totalCount = snapshot.data ?? 0;
                                        return Text(
                                          totalCount.toString(),
                                          style: TextStyle(
                                              fontSize: 36.sp,
                                              color: AppColors.colorAlert,
                                              fontWeight: FontWeight.bold),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(width: 40.w),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.access_time,
                                          color: AppColors.colorWhiteHighEmp,
                                        ),
                                      ),
                                      Text(
                                        'daily_count'.tr,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: AppColors.colorWhiteHighEmp,
                                        ),
                                      )
                                    ],
                                  ),
                                  FutureBuilder<int>(
                                    future: Provider.of<ZikirProvider>(context)
                                        .getTotalCountLast7Days(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else {
                                        int totalCount = snapshot.data ?? 0;
                                        return Text(
                                          (totalCount / 7).toInt().toString(),
                                          style: TextStyle(
                                              fontSize: 36.sp,
                                              color: AppColors.colorAlert,
                                              fontWeight: FontWeight.bold),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
