import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:manara/presentation/views/home/tasbih_count_summery_screen.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/Providers/counter_provider.dart';
import '../../../data/viewmodel/Providers/db_helper/helper_function.dart';
import '../../../data/viewmodel/Providers/models/note_model.dart';
import '../../../data/viewmodel/Providers/models/zikir_model.dart';
import '../../../data/viewmodel/Providers/note_provider.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/custom_appbar_widget.dart';

class TasbihCounterScreen extends StatefulWidget {
  final String data;

  const TasbihCounterScreen({super.key, required this.data});

  @override
  State<TasbihCounterScreen> createState() => _TasbihCounterScreenState();
}

class _TasbihCounterScreenState extends State<TasbihCounterScreen> {
  int countNumber = 0;
  int secondaryCountNumber = 0;
  late Stopwatch _stopwatch;
  late Timer _timer;
  DateTime? date;
  late ZikirProvider zikirProvider;

  //For textField which saving note
  final noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_stopwatch.isRunning) {
        updateElapsedTime();
      }
    });
    _stopwatch.start();
    Provider.of<NoteProvider>(context, listen: false).getAllNotes();
  }

  void updateElapsedTime() {
    if (mounted) {
      setState(() {}); // Trigger a rebuild
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    saveZikir(); // Cancel the timer to avoid calling setState after dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    zikirProvider = Provider.of<ZikirProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final zikirProvider = Provider.of<ZikirProvider>(context, listen: false);
    Duration duration = _stopwatch.elapsed;
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return Scaffold(
      resizeToAvoidBottomInset: false, // Disable automatic resizing
      body: Stack(
        children: [
          // Background Image
          AppBackgroundImageWidget(bgImagePath: AssetsPath.secondaryBGSVG),
          CustomAppbarWidget(screenTitle: 'tasbih_counter'.tr),
          Positioned(
            bottom: 0.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  widget.data,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppColors.colorAlert, fontSize: 20.sp),
                ),
                SizedBox(
                  height: 30.h,
                ),
                _buildTime(hours, minutes, seconds),
                SizedBox(height: 30.h),
                _buildCounts(),
                SizedBox(height: 10.h),
                _buildSwiperCount(),
                SizedBox(height: 10.h),
                _buildBottomcontents(),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTime(int hours, int minutes, int seconds) {
    return Container(
      height: 40.h,
      width: 90.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.colorWhiteLowEmp.withOpacity(0.2)),
      child: Center(
        child: Text(
          '${hours > 0 ? '$hours:' : ''}${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(color: AppColors.colorWhiteHighEmp, fontSize: 20.sp),
        ),
      ),
    );
  }

  Widget _buildCounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'tasbih_counter'.tr,
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeights.regular,
              color: AppColors.colorWhiteHighEmp),
        ),
        Text(
          '$countNumber',
          style: TextStyle(
              color: AppColors.colorAlert,
              fontSize: 100.sp,
              fontWeight: FontWeights.black),
        ),
        SizedBox(height: 60.h),
        Visibility(
          visible: countNumber == 0, // Set the condition to show/hide the Row
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_ios,
                size: 18.h,
                color: AppColors.colorWhiteHighEmp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Swipe'.tr,
                style: TextStyle(
                  color: AppColors.colorWhiteHighEmp,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.arrow_forward_ios,
                size: 18.h,
                color: AppColors.colorWhiteHighEmp,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwiperCount() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 75.h,
          width: 280.w,
          decoration: BoxDecoration(
            color: AppColors.colorBlack.withOpacity(.4),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Swiper(
            loop: true,
            scrollDirection: Axis.horizontal,
            duration: 800,
            itemCount: 100,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  SizedBox(width: 110.w),
                  Padding(
                    padding: EdgeInsets.all(2.h),
                    child: Container(
                      height: 60.w,
                      width: 60.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.colorWhiteHighEmp,
                      ),
                    ),
                  ),
                ],
              );
            },
            onIndexChanged: (int demo) {
              setState(() {
                countNumber++;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomcontents() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
      child: Container(
        height: 85.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 40.h, right: 40.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    countNumber = 0;
                  });
                },
                child: Icon(
                  Icons.refresh,
                  color: AppColors.colorWhiteHighEmp,
                  size: 25.sp,
                ),
              ),
              InkWell(
                onTap: () {
                  _showSimpleDialogForAddNotes();
                },
                child: Icon(
                  Icons.save,
                  color: AppColors.colorWhiteHighEmp,
                  size: 22.sp,
                ),
              ),
              InkWell(
                onTap: () {
                  _showSimpleDialogForAllNotes();
                },
                child: Icon(
                  Icons.history,
                  color: AppColors.colorWhiteHighEmp,
                  size: 25.sp,
                ),
              ),
              InkWell(
                onTap: () {
                  saveZikir();
                  secondaryCountNumber = countNumber;
                  Get.to(const TasbihCountSummaryScreen());
                },
                child: Icon(
                  Icons.bar_chart,
                  color: AppColors.colorWhiteHighEmp,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Dialog for adding notes
  Future<void> _showSimpleDialogForAddNotes() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppColors.colorWhiteHighEmp,
          child: SizedBox(
            height: 420.h,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: SvgPicture.asset(
                      AssetsPath.popupBGSVG,
                      alignment: Alignment.topCenter,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'what_are_you_reading'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.colorBlackHighEmp,
                      fontWeight: FontWeights.semiBold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: noteController,
                          decoration: InputDecoration(
                              hintText: 'subhanallah_33_times'.tr,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: const BorderSide(
                                      color: AppColors.colorWhiteLowEmp,
                                      width: 1))),
                          textAlign: TextAlign.center,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'this_field_must_not_be_empty'.tr;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      saveNote();
                      Navigator.pop(context);
                      showMsg(context, 'added_successfully'.tr);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 80, right: 80),
                      height: 36.h,
                      width: 140.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.colorButtonGradientStart,
                            AppColors.colorButtonGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          'add'.tr,
                          style: TextStyle(
                              color: AppColors.colorBlackHighEmp,
                              fontSize: 14.sp,
                              fontWeight: FontWeights.semiBold),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'close'.tr,
                          style: TextStyle(
                              color: AppColors.colorDisabled,
                              fontSize: 14.sp,
                              fontWeight: FontWeights.regular),
                        )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ///Dialog for showing saved notes
  Future<void> _showSimpleDialogForAllNotes() async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppColors.colorWhiteHighEmp,
          child: SizedBox(
            height: 500.h,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: SvgPicture.asset(
                    AssetsPath.popupBGSVG,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'tasbih_note'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: AppColors.colorBlackHighEmp,
                    fontWeight: FontWeights.semiBold,
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 120.h,
                  child: Consumer<NoteProvider>(
                    builder: (context, provider, child) => ListView.builder(
                      itemCount: provider.noteList.length,
                      itemBuilder: (context, index) {
                        final note = provider.noteList[index];
                        return Column(
                          children: [
                            Container(
                              height: 30.h,
                              margin: EdgeInsets.symmetric(horizontal: 24.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                    color: AppColors.colorWhiteLowEmp),
                              ),
                              child: Center(
                                child: Text(
                                  note.note,
                                  style: TextStyle(
                                    color: AppColors.colorBlackHighEmp,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeights.regular,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 3.h),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () {
                    deleteNotes(context, noteProvider);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 80.w, right: 80.w),
                    height: 36.h,
                    width: 140.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.colorButtonGradientStart,
                          AppColors.colorButtonGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'clear_note'.tr,
                        style: TextStyle(
                          color: AppColors.colorBlackHighEmp,
                          fontSize: 14.sp,
                          fontWeight: FontWeights.semiBold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'close'.tr,
                      style: TextStyle(
                        color: AppColors.colorDisabled,
                        fontSize: 14.sp,
                        fontWeight: FontWeights.regular,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Method for save notes
  void saveNote() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      final note = NoteModel(note: noteController.text);
      noteProvider.insertNote(note).then((value) {
        noteProvider.getAllNotes();
        noteController.clear();
      }).catchError((error) {
        print(error.toString());
      });
    }
  }

  //Method for delete exiting notes
  void deleteNotes(BuildContext context, NoteProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.colorPrimary,
        title: Text(
          'clear_all_notes'.tr,
          style: const TextStyle(color: AppColors.colorAlert),
        ),
        content: Text(
          'are_you_sure_to_clear_all_notes'.tr,
          style: const TextStyle(color: AppColors.colorWhiteHighEmp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'no'.tr,
              style: const TextStyle(color: AppColors.colorWhiteHighEmp),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteNotes().then((value) {
                Navigator.pop(context);
                provider.getAllNotes();
              });
            },
            child: Text(
              'yes'.tr,
              style: const TextStyle(color: AppColors.colorAlert),
            ),
          )
        ],
      ),
    );
  }

  //Method for save count
  void saveZikir() {
    date = DateTime.now();
    final zikir = ZikirModel(
        date: getFormattedDate(date!, 'dd/MM/yyyy'),
        name: widget.data,
        count: countNumber - secondaryCountNumber);
    zikirProvider.insertZikir(zikir).then((value) {
      zikirProvider.getAllZikirs();
    }).catchError((error) {
      print(error.toString());
    });
  }
}
class TouchedBallInfo {
  final String? side;
  final int? index;

  TouchedBallInfo({this.side, this.index});
}

class BallManagementDemo extends StatefulWidget {
  @override
  _BallManagementDemoState createState() => _BallManagementDemoState();
}

class _BallManagementDemoState extends State<BallManagementDemo> {
  // Control points for the curved path
  late Path _path;
  late List<Offset> _pathPoints;
  final int _numPoints = 100;

  // Ball management - separate lists for left and right
  List<BallData> _leftBalls = [];
  List<BallData> _rightBalls = [];
  List<BallData> _deletedBalls = [];
  final int _maxDisplayedBalls = 4;
  final int _maxTotalBalls = 5;

  // Input control
  final TextEditingController _numberController = TextEditingController();
  int _totalBalls = 5;
  int _nextBallId = 5; // Track the next ball ID to create

  // Dragging state
  int? _draggingBallIndex;
  String? _draggingBallSide; // 'left' or 'right'
  double _dragPosition = 0.0;
  bool _isDragging = false;

  // Animation and feedback
  bool _isAnimating = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _path = Path();
    _pathPoints = [];
    _numberController.text = _totalBalls.toString();
    _initializeBalls();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializePath();
  }

  void _initializePath() {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);

    // Create a longer but narrower curved path (quadratic Bézier curve)
    _path.moveTo(0, center.dy); // Extended start point to edge
    _path.quadraticBezierTo(
        center.dx, center.dy - 120, // Further reduced height for narrower curve
        size.width, center.dy       // Extended end point to edge
    );

    // Generate points along the path for hit testing
    _pathPoints = [];
    final metric = _path.computeMetrics().first;
    for (int i = 0; i <= _numPoints; i++) {
      final tangent = metric.getTangentForOffset(metric.length * i / _numPoints);
      _pathPoints.add(tangent!.position);
    }
  }

  void _initializeBalls() {
    _leftBalls.clear();
    _rightBalls.clear();
    _deletedBalls.clear();
    _nextBallId = 5; // Reset to start after initial 5 balls

    // Initialize only the first 5 balls (or total if less than 5)
    final initialBalls = _totalBalls < 5 ? _totalBalls : 5;

    for (int i = 0; i < initialBalls; i++) {
      final displayPosition = i * 0.08; // Reduced spacing to fit on left side

      _leftBalls.add(BallData(
        id: i,
        position: displayPosition,
        color: Colors.primaries[i % Colors.primaries.length],
      ));
    }
  }

  Offset _getPositionAlongPath(double t) {
    final metric = _path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * t.clamp(0.0, 1.0));
    return tangent!.position;
  }

  double _findNearestPathPosition(Offset point) {
    double minDistance = double.infinity;
    int nearestIndex = 0;

    for (int i = 0; i < _pathPoints.length; i++) {
      final distance = (point - _pathPoints[i]).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex / _numPoints;
  }

  // Find which ball was touched
  TouchedBallInfo _findTouchedBall(Offset touchPosition) {
    // Check left balls - check all balls, not just visible ones
    for (int i = 0; i < _leftBalls.length; i++) {
      final ball = _leftBalls[i];
      // Only check balls that are in visible positions (first 5)
      if (i < 5) {
        final ballPosition = _getPositionAlongPath(ball.position);
        final distance = (touchPosition - ballPosition).distance;

        if (distance < 30) {
          return TouchedBallInfo(side: 'left', index: i);
        }
      }
    }

    // Check right balls
    for (int i = 0; i < _rightBalls.length; i++) {
      final ballPosition = _getPositionAlongPath(_rightBalls[i].position);
      final distance = (touchPosition - ballPosition).distance;

      if (distance < 30) {
        return TouchedBallInfo(side: 'right', index: i);
      }
    }

    return TouchedBallInfo(side: null, index: null);
  }

  // Check if a ball can be dragged
  bool _canDragBall(int ballIndex, String side) {
    final balls = side == 'left' ? _leftBalls : _rightBalls;

    // For left balls, only allow dragging if it's in the visible range
    if (side == 'left' && ballIndex >= 5) {
      return false;
    }

    // For left side: only allow dragging the rightmost visible ball (last visible ball)
    if (side == 'left') {
      final lastVisibleIndex = (balls.length - 1).clamp(0, 4); // Max 5 visible balls (0-4)
      return ballIndex == lastVisibleIndex;
    }

    // For right side: only allow dragging the last visible ball (rightmost visible ball)
    if (side == 'right') {
      final visibleBalls = balls.length > 5 ? 5 : balls.length;
      final lastVisibleIndex = visibleBalls - 1;
      return ballIndex == lastVisibleIndex;
    }

    return false;
  }

  void _animateBallToPosition(int ballIndex, String side, double targetPosition, VoidCallback onComplete) {
    const duration = Duration(milliseconds: 300); // Faster animation for rearranging
    const steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final balls = side == 'left' ? _leftBalls : _rightBalls;

    // Use fixed starting positions to eliminate "going back" effect
    double startPosition;
    if ((side == 'left' && targetPosition > 0.4) || (side == 'right' && targetPosition < 0.4)) {
      // Any ball crossing the activation line starts from the activation line position
      startPosition = 0.4;
    } else {
      // Normal rearrangement - use current position
      startPosition = balls[ballIndex].position;
    }

    final positionStep = (targetPosition - startPosition) / steps;

    int currentStep = 0;

    void animate() {
      if (currentStep < steps && !_isPaused) {
        setState(() {
          // Move directly along the curve path, not to the bottom
          balls[ballIndex].position = startPosition + (positionStep * currentStep);
        });
        currentStep++;
        Future.delayed(Duration(milliseconds: stepDuration), animate);
      } else {
        setState(() {
          balls[ballIndex].position = targetPosition;
        });
        onComplete();
      }
    }

    animate();
  }

  // Handle ball movement to the right
  void _moveBallToRight(int ballIndex) {
    if (_isPaused || _isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    // Animate the ball directly to the right side position
    final targetPosition = 0.92 - (_rightBalls.length * 0.08);
    _animateBallToPosition(ballIndex, 'left', targetPosition, () {
      // When animation completes, move ball from left to right list
      final ball = _leftBalls.removeAt(ballIndex);
      ball.position = targetPosition;
      _rightBalls.add(ball);

      // Only add a new ball if we haven't created all balls yet
      if (_nextBallId < _totalBalls) {
        final newBall = BallData(
          id: _nextBallId,
          position: (_leftBalls.length) * 0.08, // Rightmost position
          color: Colors.primaries[_nextBallId % Colors.primaries.length],
        );
        _leftBalls.add(newBall); // Add to the end (rightmost)
        _nextBallId++; // Increment for next ball
      }

      // Rearrange remaining balls to fill the gap
      _rearrangeLeftBalls();

      // Manage right list if it exceeds maximum
      _manageRightList();

      setState(() {
        _isAnimating = false;
      });
    });
  }

  // Handle ball movement to the left
  void _moveBallToLeft(int ballIndex) {
    if (_isPaused || _isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    // Animate the ball directly to the left side position
    // Ensure the target position is on the left side (less than 0.4)
    final targetPosition = (_leftBalls.length * 0.08).clamp(0.0, 0.32); // Max 4 balls on left (4 * 0.08 = 0.32)
    _animateBallToPosition(ballIndex, 'right', targetPosition, () {
      // When animation completes, move ball from right to left list
      final ball = _rightBalls.removeAt(ballIndex);
      ball.position = targetPosition;
      _leftBalls.add(ball); // Add to the end

      // Rearrange left balls to make room for the new ball
      _rearrangeLeftBalls();

      // Add a new ball to the right side from deleted list if available
      if (_deletedBalls.isNotEmpty) {
        final newBall = _deletedBalls.removeLast();
        newBall.position = 0.92 - (_rightBalls.length * 0.08);
        _rightBalls.add(newBall);

        // Provide haptic feedback
        HapticFeedback.lightImpact();
      }

      // Only restore a deleted ball to left side if we have deleted balls AND we haven't created all balls yet
      if (_deletedBalls.isNotEmpty && _nextBallId < _totalBalls) {
        final restoredBall = _deletedBalls.removeLast();
        restoredBall.position = (_leftBalls.length) * 0.08; // Add to rightmost position
        _leftBalls.add(restoredBall); // Add to the end
        _nextBallId++; // Increment for the restored ball

        // Rearrange left balls again after adding the restored ball
        _rearrangeLeftBalls();

        // Provide haptic feedback
        HapticFeedback.lightImpact();
      }

      setState(() {
        _isAnimating = false;
      });
    });
  }

  void _manageRightList() {
    // Always keep only 5 balls maximum on the right side
    while (_rightBalls.length > _maxTotalBalls) {
      // Remove the oldest ball (first in the list) and add it to deleted balls
      final removedBall = _rightBalls.removeAt(0);
      _deletedBalls.add(removedBall);

      // Provide haptic feedback
      HapticFeedback.lightImpact();
    }

    // Rearrange balls on the right side based on curve with delay to prevent flickering
    Future.delayed(Duration(milliseconds: 100), () {
      _arrangeBallsOnRight();
    });
  }

  void _rearrangeLeftBalls() {
    // Animate balls to their new positions smoothly - handle all visible balls
    for (int i = 0; i < _leftBalls.length && i < 5; i++) {
      final targetPosition = i * 0.08;
      // Use a longer delay to ensure main animation completes first
      Future.delayed(Duration(milliseconds: 200), () {
        _animateBallToPosition(i, 'left', targetPosition, () {});
      });
    }
  }

  void _arrangeBallsOnRight() {
    // Only arrange the visible balls (first 5) on the right side
    final visibleBalls = _rightBalls.length > 5 ? 5 : _rightBalls.length;

    // Animate balls to their new positions smoothly
    for (int i = 0; i < visibleBalls; i++) {
      final targetPosition = 0.92 - (i * 0.08);
      _animateBallToPosition(i, 'right', targetPosition, () {});
    }
  }


  double _findAvailablePosition() {
    // Find an available position on the left side with proper spacing
    final usedPositions = _leftBalls.map((ball) => ball.position).toList();
    usedPositions.sort();

    // Try to find a gap or use the next available position with 0.08 spacing
    for (int i = 0; i < 5; i++) {
      final testPosition = i * 0.08;
      if (!usedPositions.any((pos) => (pos - testPosition).abs() < 0.04)) {
        return testPosition;
      }
    }

    // If no gap found, use the next position after the last ball
    return _leftBalls.length * 0.08;
  }

  void _updateTotalBalls() {
    final newTotal = int.tryParse(_numberController.text) ?? _totalBalls;
    if (newTotal != _totalBalls && newTotal > 0) {
      setState(() {
        _totalBalls = newTotal;
        _initializeBalls();
      });
    }
  }

  void _slideRight() {
    // Find the rightmost draggable ball on the left side
    for (int i = _leftBalls.length - 1; i >= 0 && i < 5; i--) {
      if (_canDragBall(i, 'left')) {
        _moveBallToRight(i);
        break;
      }
    }
  }

  void _slideLeft() {
    // Find the rightmost draggable ball on the right side
    for (int i = _rightBalls.length - 1; i >= 0 && i < 5; i--) {
      if (_canDragBall(i, 'right')) {
        _moveBallToLeft(i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ball Management System'),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                _isPaused = !_isPaused;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Number input section
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Number of Balls',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _updateTotalBalls,
                  child: Text('Update'),
                ),
              ],
            ),
          ),

          // Slide buttons section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _slideRight,
                  icon: Icon(Icons.arrow_forward),
                  label: Text('Slide Right'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _slideLeft,
                  icon: Icon(Icons.arrow_back),
                  label: Text('Slide Left'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Right Side: ${_rightBalls.length}/5',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _rightBalls.length >= 5 ? Colors.red : Colors.green,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Deleted: ${_deletedBalls.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Left Side: ${_leftBalls.length} (${_leftBalls.take(5).length} visible)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Row(
              children: [
                // Left side - curved path with balls
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onPanStart: (details) {
                      if (_isPaused) return;

                      final touchedBall = _findTouchedBall(details.localPosition);

                      if (touchedBall.side != null && touchedBall.index != null && _canDragBall(touchedBall.index!, touchedBall.side!)) {
                        setState(() {
                          _draggingBallIndex = touchedBall.index;
                          _draggingBallSide = touchedBall.side;
                          final balls = touchedBall.side == 'left' ? _leftBalls : _rightBalls;
                          _dragPosition = balls[touchedBall.index!].position;
                          _isDragging = true;
                        });
                      }
                    },
                    onPanUpdate: (details) {
                      if (_draggingBallIndex != null && _draggingBallSide != null && !_isPaused) {
                        final newPosition = _findNearestPathPosition(details.localPosition);
                        final balls = _draggingBallSide == 'left' ? _leftBalls : _rightBalls;

                        // Check if moving to the right side
                        if (newPosition > 0.4 && balls[_draggingBallIndex!].position <= 0.4) {
                          _moveBallToRight(_draggingBallIndex!);
                          _draggingBallIndex = null;
                          _draggingBallSide = null;
                          _isDragging = false;
                          return;
                        }

                        // Check if moving to the left side
                        if (newPosition < 0.4 && balls[_draggingBallIndex!].position >= 0.4) {
                          _moveBallToLeft(_draggingBallIndex!);
                          _draggingBallIndex = null;
                          _draggingBallSide = null;
                          _isDragging = false;
                          return;
                        }

                        // Normal dragging
                        bool canMove = true;

                        // Check collision with other balls
                        for (int i = 0; i < balls.length; i++) {
                          if (i != _draggingBallIndex) {
                            if ((balls[i].position - newPosition).abs() < 0.05) {
                              canMove = false;
                              break;
                            }
                          }
                        }

                        if (canMove) {
                          setState(() {
                            _dragPosition = newPosition.clamp(0.0, 1.0);
                          });
                        }
                      }
                    },
                    onPanEnd: (details) {
                      if (_draggingBallIndex != null && _draggingBallSide != null) {
                        final balls = _draggingBallSide == 'left' ? _leftBalls : _rightBalls;
                        setState(() {
                          balls[_draggingBallIndex!].position = _dragPosition;
                          _draggingBallIndex = null;
                          _draggingBallSide = null;
                          _isDragging = false;
                        });
                      }
                    },
                    child: CustomPaint(
                      painter: PathPainter(_path),
                      child: Stack(
                        children: [
                          // Left balls - only show first 5 visible
                          ..._leftBalls.take(5).toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final ball = entry.value;
                            final isDragging = index == _draggingBallIndex && _draggingBallSide == 'left';
                            final position = isDragging ? _dragPosition : ball.position;
                            final ballPosition = _getPositionAlongPath(position);
                            final canDrag = _canDragBall(index, 'left');

                            return Positioned(
                              left: ballPosition.dx - 17.5, // Half of 35px
                              top: ballPosition.dy - 17.5, // Half of 35px
                              child: BallWidget(
                                isDragging: isDragging,
                                canDrag: canDrag,
                                position: position,
                                ballNumber: ball.id + 1,
                              ),
                            );
                          }),

                          // Right balls - only show first 5 visible balls
                          ..._rightBalls.take(5).toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final ball = entry.value;
                            final isDragging = index == _draggingBallIndex && _draggingBallSide == 'right';
                            final position = isDragging ? _dragPosition : ball.position;
                            final ballPosition = _getPositionAlongPath(position);
                            final canDrag = _canDragBall(index, 'right');

                            return Positioned(
                              left: ballPosition.dx - 17.5, // Half of 35px
                              top: ballPosition.dy - 17.5, // Half of 35px
                              child: BallWidget(
                                isDragging: isDragging,
                                canDrag: canDrag,
                                position: position,
                                ballNumber: ball.id + 1,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BallData {
  final int id;
  double position;
  final Color color;

  BallData({
    required this.id,
    required this.position,
    required this.color,
  });
}

class PathPainter extends CustomPainter {
  final Path path;

  PathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);

    // Draw division line
    final divisionPaint = Paint()
      ..color = Colors.red.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      divisionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BallWidget extends StatelessWidget {
  final bool isDragging;
  final bool canDrag;
  final double position;
  final int ballNumber;
  final double size;

  const BallWidget({
    Key? key,
    required this.isDragging,
    required this.canDrag,
    required this.position,
    required this.ballNumber,
    this.size = 35, // Reduced from 50 to 35
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine which image to show based on position
    final imageAsset = position > 0.4 ? 'assets/sbhaball1.png' : 'assets/sIbhaball2.png';

    return Transform.scale(
      scale: isDragging ? 1.2 : 1.0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: isDragging ? 10 : 5,
                spreadRadius: isDragging ? 2 : 1,
              )
            ]
        ),
        child: ClipOval(
          child: Image.asset(
            imageAsset,
            width: size,
            height: size,
            fit: BoxFit.cover,
            color: canDrag ? null : Colors.grey.withOpacity(0.5),
            colorBlendMode: canDrag ? null : BlendMode.saturation,
          ),
        ),
      ),
    );
  }
}
