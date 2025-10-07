import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import '../../../../purchase/purchase_api.dart';
import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../data/viewmodel/Providers/user_provider.dart';
import '../../../constants/images.dart';
import '../../widgets/app_background_image_widget.dart';

class SubscriptionAndDonationScreen extends StatefulWidget {
  const SubscriptionAndDonationScreen({super.key});

  @override
  State<SubscriptionAndDonationScreen> createState() =>
      _SubscriptionAndDonationScreenState();
}

class _SubscriptionAndDonationScreenState
    extends State<SubscriptionAndDonationScreen> {
  late Future<List<Package>> _futurePackages;

  @override
  void initState() {
    super.initState();
    _futurePackages = PurchaseApi.fetchOffersByIds(Coins.allIds)
        .then((offerings) => offerings
            .map((offer) => offer.availablePackages)
            .expand((pair) => pair)
            .toList())
        .catchError((error) {
      print('Error fetching packages: $error');
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImageWidget(
            bgImagePath: AssetsPath.secondaryBGSVG,
          ),
          FutureBuilder<List<Package>>(
              future: _futurePackages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('No packages found'));
                }
                final packages = snapshot.data!;
                print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>${packages.length}");
                return Padding(
                  padding: const EdgeInsets.only(top: 61, left: 16, right: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(AssetsPath.cancelIconSVG)),
                        SizedBox(
                          height: 5.h,
                        ),
                        Center(
                          child: Column(
                            children: [
                              _buildHeader(),
                              SizedBox(height: 24.h),
                              _buildBasicPlan(packages, context),
                               SizedBox(height: 24.h),
                              _buildMostPopuler(packages, context),
                              SizedBox(height: 10.h),
                              _buildDoner(packages, context),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'subscription_plans'.tr,
          style: TextStyle(
            color: AppColors.colorWhiteHighEmp,
            fontSize: 20.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeights.semiBold,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'donation_heading'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.colorWhiteHighEmp,
            fontSize: 12.sp,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }


  Widget _buildBasicPlan(List<Package> packages, BuildContext context) {
    return InkWell(
      onTap: () async {
        final isSuccess = await PurchaseApi.purchasePackage(packages[1]);
        if (isSuccess) {
          final data = Donation(donationAmount: 5);

          final success =
              await Provider.of<UserProvider>(context, listen: false)
                  .updateDonationInfo(data);
        } else {
          print('Huya nahi re baba firse dena padega');
        }
      },
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [
              AppColors.colorGradient1Start,
              AppColors.colorGradient1End
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic'.tr,
                          style: TextStyle(
                            color: AppColors.colorWhiteHighEmp,
                            fontSize: 16.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeights.semiBold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'yearly_des'.tr,
                          style: TextStyle(
                            color: AppColors.colorWhiteHighEmp,
                            fontSize: 10.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeights.regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 93,
                    height: 33,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: ShapeDecoration(
                      color: AppColors.colorWhiteMidEmp,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      '\$5',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.colorBlackHighEmp,
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeights.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMostPopuler(List<Package> packages, BuildContext context) {
    return InkWell(
      onTap: () async {
        final isSuccess = await PurchaseApi.purchasePackage(packages[2]);
        if (isSuccess) {
          final data = Donation(donationAmount: 15);

          final success =
              await Provider.of<UserProvider>(context, listen: false)
                  .updateDonationInfo(data);
        } else {
          print('Huya nahi re baba firse dena padega');
        }
      },
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [
              AppColors.colorDonationGradient1Start,
              AppColors.colorDonationGradient1End
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 18,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      AppColors.colorCard3GradientStart,
                      AppColors.colorCard3GradientEnd
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'mst_popular'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.colorBlackLowEmp2,
                      fontSize: 8.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeights.regular,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Advance'.tr,
                          style: TextStyle(
                            color: AppColors.colorBlackHighEmp,
                            fontSize: 16.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeights.semiBold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'yearly_des'.tr,
                          style: TextStyle(
                            color: AppColors.colorBlackHighEmp,
                            fontSize: 10.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeights.regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 93,
                    height: 33,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: ShapeDecoration(
                      color: AppColors.colorWhiteMidEmp,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      '\$15',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.colorBlackHighEmp,
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeights.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoner(List<Package> packages, BuildContext context) {
    return InkWell(
      onTap: () async {
        final isSuccess = await PurchaseApi.purchasePackage(packages[3]);
        if (isSuccess) {
          final data = Donation(donationAmount: 25);

          final success =
              await Provider.of<UserProvider>(context, listen: false)
                  .updateDonationInfo(data);
        } else {
          print('Huya nahi re baba firse dena padega');
        }
      },
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [
              AppColors.colorGradient1Start,
              AppColors.colorGradient1End
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donor'.tr,
                          style: TextStyle(
                            color: AppColors.colorWhiteHighEmp,
                            fontSize: 16.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeights.semiBold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'yearly_des'.tr,
                          style: TextStyle(
                            color: AppColors.colorWhiteHighEmp,
                            fontSize: 10.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeights.regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 93,
                    height: 33,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: ShapeDecoration(
                      color: AppColors.colorWhiteMidEmp,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      '\$25',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.colorBlackHighEmp,
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeights.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
