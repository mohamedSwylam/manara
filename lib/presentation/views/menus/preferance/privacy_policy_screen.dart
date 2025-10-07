import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/images.dart';
import '../../../widgets/loading_popup_widget.dart';
import '../../../widgets/app_background_image_widget.dart';
import '../../../widgets/custom_appbar_widget.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key, required this.privacyPolicyUrl});

  final String privacyPolicyUrl;

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.colorPrimaryLight)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _isLoading = false;
            setState(() {});
            print('entered');
            // if (url.endsWith("tran_type=success")) {
            //   navigateBack();
            // }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            print(request);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.privacyPolicyUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImageWidget(
            bgImagePath: AssetsPath.secondaryBGSVG,
          ),
           CustomAppbarWidget(screenTitle: 'privacy_policy'.tr,
          ),
          Padding(
            padding: EdgeInsets.only(top: 97.h, left: 16.h, right: 16.h, bottom: 16.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppColors.colorPrimaryLight,
              ),
              child: _isLoading
                  ? const Center(child: LoadingPopupWidget())
                  : WebViewWidget(
                      controller: _webViewController,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
