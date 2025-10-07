import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manara/presentation/views/Qibla/qibla_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constants/images.dart';

class CompassScreen extends StatefulWidget {
  final bool hideBackButton;
  
  const CompassScreen({Key? key, this.hideBackButton = false}) : super(key: key);

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> with AutomaticKeepAliveClientMixin {
  bool hasPermission = false;
  bool cancel = false;

  @override
  bool get wantKeepAlive => true;

  Future getPermission() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      if (status.isGranted) {
        hasPermission = true;
      } else {
        Permission.location.request().then((value) {
          setState(() {
            hasPermission = (value == PermissionStatus.granted);
          });
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
        body: Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              AssetsPath.pannerbgSVG,
              fit: BoxFit.contain,
            ),
          ),
        ),
         QiblahScreen(hideBackButton: widget.hideBackButton)
        // Container(
        //     decoration: BoxDecoration(
        //         image: DecorationImage(
        //       image: AssetImage(AssetsPath.background2nd),
        //       fit: BoxFit.fill,
        //     )),
        //     child: const
        //     QiblahScreen()),
        //
      ],
    ));
  }
}
