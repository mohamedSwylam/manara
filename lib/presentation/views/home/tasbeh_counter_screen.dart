import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/azkar/azkar_details_index.dart';
import '../../../data/models/azkar/azkar_model.dart';
import '../../../data/services/azkar_service.dart';

class TasbehCounterScreen extends StatefulWidget {
  final String routineName;
  final int totalCount;
  final String? categoryId;
  
  const TasbehCounterScreen({
    super.key, 
    required this.routineName,
    this.totalCount = 33,
    this.categoryId,
  });

  @override
  State<TasbehCounterScreen> createState() => _TasbehCounterScreenState();
}
class TouchedBallInfo {
  final String? side;
  final int? index;

  TouchedBallInfo({this.side, this.index});
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
      ..color = Colors.transparent
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
    final imageAsset = position > 0.4 ? 'assets/images/sbhaball1.png' : 'assets/images/sIbhaball2.png';

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
class _TasbehCounterScreenState extends State<TasbehCounterScreen> 
    with TickerProviderStateMixin {
  // Audio player for sound effects
  final AudioPlayer _audioPlayer = AudioPlayer();
  
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
  final bool _isPaused = false;

  int currentCount = 0;
  int currentRound = 1;
  int targetCount = 33;
  int currentTasbehIndex = 0;
  String? currentAzkarId; // Track current azkar ID for completion tracking

  // Animation controllers
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  // Bead state
  int leftBeads = 6;
  int rightBeads = 4;
  bool isAnimating = false;

  // Drag state
  bool isDragging = false;
  Offset dragOffset = Offset.zero;
  double dragThreshold = 100.0; // Distance needed to trigger count

  // Track constraints
  double trackStartX = 265.w; // Start position (Bead 7's original position)
  double trackEndX = 125.w;   // End position (Bead 6's position)
  double trackY = 200.h;      // Fixed Y position along the track

  final List<Map<String, String>> tasbehList = [
    {
      'english': 'In the name of Allah, the Most Compassionate, the Most Merciful.',
      'arabic': 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      'transliteration': 'Bismillah hir-Rahman nir-Rahim',
    },
    {
      'english': 'Glory be to Allah',
      'arabic': 'سُبْحَانَ اللَّهِ',
      'transliteration': 'Subhan Allah',
    },
    {
      'english': 'All praise is due to Allah',
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'transliteration': 'Alhamdulillah',
    },
    {
      'english': 'Allah is the Greatest',
      'arabic': 'اللَّهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
    },
  ];

  // 1. Add CarouselController to the state (at the top of the state class)
  final CarouselSliderController _carouselController = CarouselSliderController();

  int _modeIndex = 0; // 0: vibration, 1: sound, 2: silent
  final List<String> _modeIcons = [
    'assets/images/vibration.svg',
    'assets/images/sound.svg',
    'assets/images/no-sound.svg',
  ];
  final List<String> _modeLabels = [
    'Vibration',
    'Sound',
    'Silent',
  ];

  @override
  void initState() {
    super.initState();
    
    // Update target count based on azkar data if available
    if (widget.categoryId != null) {
      // We'll update this when azkar data is loaded
      targetCount = widget.totalCount;
    }
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    _path.moveTo(0, center.dy -300); // Extended start point to edge
    _path.quadraticBezierTo(
        center.dx, center.dy - 500, // Further reduced height for narrower curve
        size.width, center.dy -300    // Extended end point to edge
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

    // Play sound effect when counting
    _playSoundEffect();

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

      // Check if we've completed the azkar (reached target count)
      final currentCompletedCount = _deletedBalls.length + _rightBalls.length;
      if (currentCompletedCount >= targetCount && currentAzkarId != null) {
        print('🎯 Azkar completed! Count: $currentCompletedCount/$targetCount');
        // Track completion in background
        AzkarService.trackAzkarCompletion(currentAzkarId!);
      }

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

    // Play sound effect when counting
    _playSoundEffect();

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
    Future.delayed(const Duration(milliseconds: 100), () {
      _arrangeBallsOnRight();
    });
  }

  void _rearrangeLeftBalls() {
    // Animate balls to their new positions smoothly - handle all visible balls
    for (int i = 0; i < _leftBalls.length && i < 5; i++) {
      final targetPosition = i * 0.08;
      // Use a longer delay to ensure main animation completes first
      Future.delayed(const Duration(milliseconds: 200), () {
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

  // Play sound effect based on mode
  void _playSoundEffect() {
    switch (_modeIndex) {
      case 0: // Vibration mode
        HapticFeedback.lightImpact();
        break;
      case 1: // Sound mode
        _audioPlayer.play(AssetSource('beads/BeadsSoundeffict.mp3'));
        break;
      case 2: // Silent mode
        // Do nothing
        break;
    }
  }


  void incrementCount() {
    setState(() {
      currentCount++;
      if (currentCount >= targetCount) {
        currentCount = 0;
        currentRound++;
      }
    });

    // Trigger bead slide animation
    _slideBead();
  }

  void _slideBead() {
    if (isAnimating) return;

    setState(() {
      isAnimating = true;
    });

    _slideController.forward().then((_) {
      setState(() {
        // Update bead counts
        leftBeads--;
        rightBeads++;
        isAnimating = false;
      });
      _slideController.reset();
    });
  }

  void resetCounter() {
    setState(() {
      currentCount = 0;
      currentRound = 1;
      leftBeads = 6;
      rightBeads = 4;
      isAnimating = false;
      isDragging = false;
      dragOffset = Offset.zero;
      _deletedBalls = [];
      _rightBalls = [];
      _initializeBalls();
    });
    if (mounted) {
      _slideController.reset();
    }
    print('🔄 Counter reset - tracking state cleared');
  }

  @override
  void dispose() {
    _slideController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
         // If categoryId is provided, wrap with BlocProvider for azkar details
     if (widget.categoryId != null) {
       print('🎯 CategoryId passed to TasbehCounterScreen: ${widget.categoryId}');
       return BlocProvider(
         create: (context) => AzkarDetailsBloc()..add(LoadAzkarsByCategory(widget.categoryId!)),
        child: BlocBuilder<AzkarDetailsBloc, AzkarDetailsState>(
          builder: (context, azkarState) {
            return _buildScaffold(context, theme, azkarState);
          },
        ),
      );
    }
    
    // If no categoryId, use default behavior
    return _buildScaffold(context, theme, null);
  }

     Widget _buildScaffold(BuildContext context, ThemeData theme, AzkarDetailsState? azkarState) {
     return BlocListener<AzkarDetailsBloc, AzkarDetailsState>(
               listener: (context, state) {
          print('🔄 BlocListener triggered with state: ${state.runtimeType}');
          if (state is AzkarDetailsLoaded) {
            print('🔄 Updating counter from API: ${state.totalRepeatCount}');
            setState(() {
              targetCount = state.totalRepeatCount;
              _totalBalls = state.totalRepeatCount;
              _numberController.text = state.totalRepeatCount.toString();
              _initializeBalls();
            });
            
            // Set the current azkar ID for tracking completion
            if (state.azkars.isNotEmpty) {
              currentAzkarId = state.azkars[currentTasbehIndex].id;
              print('🎯 Set current azkar ID for tracking: $currentAzkarId');
            }
            
            print('✅ Counter updated: _totalBalls = $_totalBalls');
            print('✅ Target count updated: $targetCount');
          }
        },
       child: Scaffold(
         backgroundColor: theme.scaffoldBackgroundColor,
         appBar: AppBar(
           backgroundColor: theme.appBarTheme.backgroundColor,
           elevation: 0,
           leading: IconButton(
             icon: Icon(
               Icons.arrow_back_ios,
               color: theme.iconTheme.color,
               size: 24,
             ),
             onPressed: () => Navigator.of(context).pop(),
           ),
           title: Text(
             widget.routineName,
             style: GoogleFonts.poppins(
               fontSize: 18.sp,
               fontWeight: FontWeights.semiBold,
               color: theme.textTheme.titleMedium?.color,
             ),
           ),
           centerTitle: true,
           actions: [
             // Vibration/Sound/Silent toggle
             IconButton(
               icon: SvgPicture.asset(
                 _modeIcons[_modeIndex],
                 width: 24,
                 height: 24,
                 color: theme.iconTheme.color,
               ),
               tooltip: _modeLabels[_modeIndex],
               onPressed: () {
                 setState(() {
                   _modeIndex = (_modeIndex + 1) % 3;
                 });
                 // Optionally: trigger vibration/sound/silent logic here
               },
             ),
             // Reset counter
             IconButton(
               icon: Icon(
                 Icons.refresh,
                 color: theme.iconTheme.color,
                 size: 24,
               ),
               onPressed: () {
                 showDialog(
                   context: context,
                   builder: (BuildContext context) {
                     return Dialog(
                       insetPadding: const EdgeInsets.symmetric(horizontal: 32),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10),
                       ),
                       backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardTheme.color,
                       child: Container(
                         width: 296,
                         padding: const EdgeInsets.all(16),
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: [
                                 IconButton(
                                   icon: Icon(Icons.close, size: 20),
                                   padding: EdgeInsets.zero,
                                   constraints: BoxConstraints(),
                                   onPressed: () => Navigator.pop(context),
                                 ),
                               ],
                             ),
                             // Title
                             Text(
                               'Reset the Counter?',
                               style: TextStyle(
                                 fontFamily: 'IBMPlexSansArabic',
                                 fontWeight: FontWeight.w600,
                                 fontSize: 15,
                                 height: 1.33, // 20px line height
                                 color: theme.textTheme.titleMedium?.color,
                               ),
                             ),
                             const SizedBox(height: 16),

                             // Options Container
                             Container(
                               decoration: BoxDecoration(
                                 border: Border.all(width: 1, color: theme.dividerTheme.color ?? Colors.grey[300]!),
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               child: Column(
                                 children: [
                                   // Reset Current Counter
                                   ListTile(
                                     title: Text(
                                       'Reset Current Counter',
                                       textAlign: TextAlign.center,
                                       style: TextStyle(
                                         fontFamily: 'IBMPlexSansArabic',
                                         color: AppColors.colorPrimary
                                       ),
                                     ),
                                     onTap: () {
                                       resetCounter();
                                       Navigator.pop(context);
                                     }
                                   ),
                                   const Divider(height: 1),

                                   // Reset All Category Counters
                                   ListTile(
                                     title: Text(
                                       'Reset All Category Counters',
                                       textAlign: TextAlign.center,
                                       style: TextStyle(
                                         fontFamily: 'IBMPlexSansArabic',
                                         color: AppColors.colorPrimary
                                       ),
                                     ),
                                     onTap: () => Navigator.pop(context),
                                   ),
                                   const Divider(height: 1),

                                   // Cancel button
                                   TextButton(
                                     onPressed: () => Navigator.pop(context),
                                     child: Text(
                                       'Cancel',
                                       style: TextStyle(
                                         fontFamily: 'IBMPlexSansArabic',
                                         color: theme.textTheme.bodySmall?.color,
                                       ),
                                     ),
                                   ),

                                 ],
                               ),
                             ),
                             const SizedBox(height: 16),



                           ],
                         ),
                       ),
                     );
                   },
                 );
               },
             ),
           ],
         ),
         body: (azkarState is AzkarDetailsLoading)
             ? const Center(child: CircularProgressIndicator())
             : (azkarState is AzkarDetailsFailure)
                 ? Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(
                           'Failed to load azkars',
                           style: TextStyle(
                             fontSize: 16.sp,
                             color: theme.textTheme.bodyMedium?.color,
                           ),
                         ),
                         SizedBox(height: 16.h),
                         ElevatedButton(
                           onPressed: () {
                             context.read<AzkarDetailsBloc>().add(LoadAzkarsByCategory(widget.categoryId!));
                           },
                           child: const Text('Retry'),
                         ),
                       ],
                     ),
                   )
                 : SingleChildScrollView(
                     child: Column(
                       children: [
                         SizedBox(height: 20.h,),
                         // Prayer/Dua Banner Card
                         _buildPrayerBanner(theme, azkarState),
                         SizedBox(height: 30.h),
                         // Main content area
                         GestureDetector(
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
                             child: SizedBox(
                               height: 300.h,
                               width: double.infinity,
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

                                   Positioned(
                                     top: 60.h,
                                     child: Center(
                                       child: GestureDetector(
                                         onTap: () {
                                           _playSoundEffect();
                                           _slideRight();
                                         },
                                         onHorizontalDragEnd: (DragEndDetails details) {
                                           if (details.primaryVelocity! < 0) {
                                             _playSoundEffect();
                                             _slideLeft();
                                             print("Swiped Left →");
                                           } else if (details.primaryVelocity! > 0) {
                                             _playSoundEffect();
                                             _slideRight();
                                             print("Swiped Right ←");
                                           }
                                         },
                                         child: Container(
                                           width: 400.w,
                                           color: Colors.transparent,
                                           height: 200.h,
                                         ),
                                       ),
                                     ),
                                   ),
                                   // Counter under curve
                                   Positioned(
                                     left: 0,
                                     right: 0,
                                     top: 80.h,
                                     child: Padding(
                                       padding: EdgeInsets.only(bottom: 12.h),
                                       child: Center(
                                         child: Column(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           crossAxisAlignment: CrossAxisAlignment.center,
                                           children: [
                                             Row(
                                               mainAxisAlignment: MainAxisAlignment.center,
                                               crossAxisAlignment: CrossAxisAlignment.end,
                                               children: [
                                                 Text(
                                                   '	${_deletedBalls.length + _rightBalls.length}',
                                                   style: TextStyle(
                                                     fontSize: 64.sp,
                                                     fontWeight: FontWeight.bold,
                                                     color: theme.textTheme.titleLarge?.color,
                                                   ),
                                                 ),
                                                 Padding(
                                                   padding: EdgeInsets.only(bottom: 10.h),
                                                   child: Row(
                                                     crossAxisAlignment: CrossAxisAlignment.end,
                                                     children: [
                                                                                                            Builder(
                                                         builder: (context) {
                                                           print('🎯 Displaying counter: $_totalBalls (targetCount: $targetCount)');
                                                           return Text(
                                                             '/ ${_totalBalls.toString()}',
                                                            style: TextStyle(
                                                              fontSize: 32.sp,
                                                              color: theme.textTheme.bodySmall?.color,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      GestureDetector(
                                                        onTap: () {
                                                          _showRepetitionCountBottomSheet(context);
                                                        },
                                                        child: SvgPicture.asset(
                                                          AssetsPath.editSVG,
                                                          width: 24.w,
                                                          height: 24.h,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Rounds: ',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: theme.textTheme.bodySmall?.color,
                                                  ),
                                                ),
                                                Text(
                                                  '$currentRound',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.textTheme.titleMedium?.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 12.h),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  AssetsPath.swipeSVG,
                                                  width: 24.w,
                                                  height: 24.h,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'Click or swipe to count',
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color: theme.textTheme.bodyMedium?.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '(right-left swipe will decrease count)',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: theme.textTheme.bodySmall?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
       ),
     );
   }
  Widget _buildPrayerBanner(ThemeData theme, AzkarDetailsState? azkarState) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.8;
    return Stack(
      alignment: Alignment.center,
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 230.h + 38.h,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            enableInfiniteScroll: true,
            autoPlay: false,
            pageSnapping: true,
            animateToClosest: false,
            disableCenter: true,
                         onPageChanged: (index, reason) {
               setState(() {
                 currentTasbehIndex = index;
               });
               
               // Update current azkar ID when switching azkars
               if (azkarState is AzkarDetailsLoaded && azkarState.azkars.isNotEmpty && index < azkarState.azkars.length) {
                 currentAzkarId = azkarState.azkars[index].id;
                 print('🎯 Switched to azkar ID: $currentAzkarId (index: $index)');
               }
             },
            initialPage: currentTasbehIndex,
          ),
          items: _getCarouselItems(azkarState).asMap().entries.map((entry) {
            var item = entry.value;
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: cardWidth,
                  height: 230.h + 38.h,
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        child: Column(
                          children: [
                            Text(
                              item['english']!,
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeights.medium,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              item['arabic']!,
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeights.semiBold,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              item['transliteration']!,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeights.regular,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24.r)),
                            child: SvgPicture.asset(
                              AssetsPath.pannerbgSVG,
                              fit: BoxFit.fitHeight,
                              width: cardWidth,
                              height: 59.2.h,
                              color: const Color(0xFFD5CCA1),
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(24.r)),
                            child: SvgPicture.asset(
                              AssetsPath.pannerbgSVG,
                              fit: BoxFit.fitHeight,
                              width: cardWidth,
                              height: 59.2.h,
                              color: const Color(0xFFD5CCA1),
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        // Left arrow
        Positioned(
          left: 0,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
            onPressed: () {
              // Navigation handled by swipe gestures
            },
          ),
        ),
        // Right arrow
        Positioned(
          right: 0,
          child: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
            onPressed: () {
              // Navigation handled by swipe gestures
            },
          ),
        ),
      ],
    );
  }

  void _showRepetitionCountBottomSheet(BuildContext context, {int? editCustomValue, int? editCustomIndex}) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _RepetitionCountBottomSheet(
          theme: theme,
          initialValue: _totalBalls,
          onValueSelected: (int value) {
            setState(() {
              _numberController.text = value.toString();
              _updateTotalBalls();
            });
            Navigator.pop(context);
          },
          editCustomValue: editCustomValue,
          editCustomIndex: editCustomIndex,
          onCustomEdited: (int newValue, int index) {
            setState(() {
              // This will be handled by the callback
            });
          },
          onCustomDeleted: (int index) {
            setState(() {
              // This will be handled by the callback
            });
          },
          onEditCustom: (int value, int index) {
            Navigator.pop(context);
            Future.delayed(Duration.zero, () {
              _showRepetitionCountBottomSheet(
                context,
                editCustomValue: value,
                editCustomIndex: index,
              );
            });
          },
        );
      },
    );
  }

  List<Map<String, String>> _getCarouselItems(AzkarDetailsState? azkarState) {
    // If we have azkar data from API, use it
    if (widget.categoryId != null) {
      if (azkarState is AzkarDetailsLoaded && azkarState.azkars.isNotEmpty) {
        final locale = Get.locale?.languageCode ?? 'en';
        return azkarState.azkars.map((azkar) => {
          'english': azkar.getAzkarText(locale),
          'arabic': azkar.azkarArabic,
          'transliteration': azkar.azkarEnglish,
          'repeat_count': azkar.repeatCount.toString(),
        }).toList();
      }
    }
    
    // Fallback to default tasbeh list
    return tasbehList;
  }

}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF666666) // Dark grey color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0; // Medium thickness

    final center = Offset(size.width / 2, size.height * 1.2);
    final radius = size.width * 0.55;

    // Draw the main arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      9.7, // Start angle (left side)
      2.5, // Sweep angle (right side)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RepetitionCountBottomSheet extends StatefulWidget {
  final ThemeData theme;
  final int initialValue;
  final void Function(int) onValueSelected;
  final int? editCustomValue;
  final int? editCustomIndex;
  final void Function(int, int)? onCustomEdited;
  final void Function(int)? onCustomDeleted;
  final void Function(int, int)? onEditCustom;
  const _RepetitionCountBottomSheet({
    required this.theme,
    required this.initialValue,
    required this.onValueSelected,
    this.editCustomValue,
    this.editCustomIndex,
    this.onCustomEdited,
    this.onCustomDeleted,
    this.onEditCustom,
  });
  @override
  State<_RepetitionCountBottomSheet> createState() => _RepetitionCountBottomSheetState();
}

class _RepetitionCountBottomSheetState extends State<_RepetitionCountBottomSheet> {
  final List<int> presetCounts = [7, 10, 33, 100, 200];
  List<int> customCounts = [];
  int? selectedCount;
  bool showCustomInput = false;
  TextEditingController customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If initial value is not preset, treat as custom
    if (!presetCounts.contains(widget.initialValue)) {
      customCounts.add(widget.initialValue);
      selectedCount = widget.initialValue;
    } else {
      selectedCount = widget.initialValue;
    }
    
    // If editing a custom value, set up the edit mode
    if (widget.editCustomValue != null) {
      showCustomInput = true;
      customController.text = widget.editCustomValue.toString();
      selectedCount = widget.editCustomValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                showCustomInput
                  ? (widget.editCustomValue != null ? 'Edit Custom Count' : 'Add Custom Count')
                  : 'Set the Number of Repetitions',
                style: TextStyle(
                  fontSize: 18.sp, 
                  fontWeight: FontWeight.bold,
                  color: widget.theme.textTheme.titleMedium?.color,
                ),
              ),
              IconButton(
                                 icon: Icon(Icons.close, color: widget.theme.textTheme.bodyMedium?.color),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (!showCustomInput) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...presetCounts.map((count) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCount = count;
                        });
                      },
                      child: selectedCount == count
                          ? Container(
                              width: 64.w,
                              height: 64.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8D1B3D).withOpacity(0.06),
                                borderRadius: BorderRadius.circular(32.w),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: widget.theme.textTheme.titleLarge?.color,
                                ),
                              ),
                            )
                          : Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: widget.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                    ),
                  )),
                  ...customCounts.map((count) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCount = count;
                        });
                      },
                      child: selectedCount == count
                          ? Row(
                              children: [
                                Container(
                                  width: 64.w,
                                  height: 64.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8D1B3D).withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(32.w),
                                  ),
                                                                     child: Text(
                                     count.toString(),
                                     style: TextStyle(
                                       fontSize: 28.sp,
                                       fontWeight: FontWeight.bold,
                                       color: widget.theme.textTheme.titleLarge?.color,
                                     ),
                                   ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (widget.onEditCustom != null) {
                                      widget.onEditCustom!(count, customCounts.indexOf(count));
                                    }
                                  },
                                  child: SvgPicture.asset(
                                    AssetsPath.editSVG,
                                    width: 24.w,
                                    height: 24.h,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                            children: [
                                                             Text(
                                 count.toString(),
                                 style: TextStyle(
                                   fontSize: 28.sp,
                                   fontWeight: FontWeight.bold,
                                   color: widget.theme.textTheme.bodySmall?.color,
                                 ),
                               ),
                              InkWell(
                                onTap: () {
                                  if (widget.onEditCustom != null) {
                                    widget.onEditCustom!(count, customCounts.indexOf(count));
                                  }
                                },
                                child: SvgPicture.asset(
                                  AssetsPath.editSVG,
                                  width: 24.w,
                                  height: 24.h,
                                ),
                              ),
                            ],
                          ),
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        side: BorderSide(color: widget.theme.textTheme.bodySmall?.color ?? Colors.grey),
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: () {
                        setState(() {
                          showCustomInput = true;
                          customController.clear();
                          selectedCount = null;
                        });
                      },
                                             child: Icon(Icons.add, color: widget.theme.textTheme.bodySmall?.color),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Center(
              child: ElevatedButton(
                onPressed: selectedCount != null ? () => widget.onValueSelected(selectedCount!) : null,
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D1B3D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customController,
                    keyboardType: TextInputType.number,
                                         decoration: InputDecoration(
                       hintText: '0',
                       border: const OutlineInputBorder(),
                       hintStyle: TextStyle(color: widget.theme.textTheme.bodySmall?.color),
                     ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(3),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (val) {
                      int? value = int.tryParse(val);
                      if (value != null && value > 999) {
                        customController.text = '999';
                        customController.selection = TextSelection.fromPosition(
                          TextPosition(offset: customController.text.length),
                        );
                        value = 999;
                      }
                      setState(() {
                        selectedCount = value;
                      });
                    },
                  ),
                ),
                if (widget.editCustomValue != null)
                                     IconButton(
                     icon: Icon(Icons.delete_outline, color: widget.theme.textTheme.bodyMedium?.color),
                    onPressed: () {
                      if (widget.onCustomDeleted != null && widget.editCustomIndex != null) {
                        widget.onCustomDeleted!(widget.editCustomIndex!);
                      }
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            SizedBox(height: 24.h),
            Center(
              child: ElevatedButton(
                onPressed: (selectedCount != null && selectedCount! > 0 && selectedCount! <= 999)
                    ? () {
                        if (widget.editCustomValue != null && widget.editCustomIndex != null && widget.onCustomEdited != null) {
                          // Editing existing custom value
                          widget.onCustomEdited!(selectedCount!, widget.editCustomIndex!);
                          // Update the local customCounts list
                          setState(() {
                            customCounts[widget.editCustomIndex!] = selectedCount!;
                            showCustomInput = false;
                          });
                        } else {
                          // Adding new custom value
                          setState(() {
                            if (!customCounts.contains(selectedCount)) {
                              customCounts.add(selectedCount!);
                            }
                            showCustomInput = false;
                          });
                        }
                      }
                    : null,
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D1B3D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
