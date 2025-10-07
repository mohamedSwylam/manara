import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../constants/colors.dart';
import '../../../data/viewmodel/Providers/link_provider.dart';

class MakkahLiveScreen extends StatefulWidget {
  const MakkahLiveScreen({Key? key}) : super(key: key);

  @override
  State<MakkahLiveScreen> createState() => _MakkahLiveScreenState();
}

class _MakkahLiveScreenState extends State<MakkahLiveScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    final videoId = YoutubePlayer.convertUrlToId(Provider.of<LinkProvider>(context, listen: false).liveLink);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        isLive: true,
        enableCaption: true,
        captionLanguage: 'en',
        controlsVisibleAtStart: true,
        hideThumbnail: false,
        hideControls: true,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorPrimary,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.colorPrimary,
                  AppColors.colorPrimaryLight,
                ],
              ),
            ),
            child: Center(
              child: YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),
                builder: (context, player) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Use Expanded to make YoutubePlayer take up all available vertical space
                      Expanded(
                        child: player,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
              top: 20.h,
              left: 20.h,
              child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                  child: const Icon(Icons.arrow_back_ios)
              )
          ),
        ],
      ),
    );
  }
}
