import 'package:banter/turorial_page.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Animation;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<CreateAccount>
    with SingleTickerProviderStateMixin {
  late File file;
  late RiveWidgetController controller;
  bool isInitialized = false;
  ViewModelInstanceTrigger? _openDraw;
  ViewModelInstanceTrigger? _openImport;
  bool isCreateAccountButtonVisible = false;
  bool isDrawingCheckmark = false;
  bool isImportScreen = false;
  bool isShowingIntro = true;
  final TextEditingController _phoneController = TextEditingController();
  final List<Offset> _drawingPoints = [];

  // Fade animation for content
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  /// Checks if the drawn pattern matches a checkmark shape
  /// Returns a confidence score between 0.0 and 1.0
  double checkCheckmarkMatch(List<Offset> points) {
    if (points.isEmpty) return 0.0;

    // Remove infinite offsets (stroke separators)
    final validPoints = points.where((p) => p.isFinite).toList();
    if (validPoints.length < 5) return 0.0; // Too few points

    // Find bounding box
    double minX = validPoints.first.dx;
    double maxX = validPoints.first.dx;
    double minY = validPoints.first.dy;
    double maxY = validPoints.first.dy;

    for (final point in validPoints) {
      minX = minX < point.dx ? minX : point.dx;
      maxX = maxX > point.dx ? maxX : point.dx;
      minY = minY < point.dy ? minY : point.dy;
      maxY = maxY > point.dy ? maxY : point.dy;
    }

    final width = maxX - minX;
    final height = maxY - minY;

    if (width < 20 || height < 20) return 0.0; // Too small

    // Normalize points to 0-1 range
    final normalized = validPoints.map((p) {
      return Offset((p.dx - minX) / width, (p.dy - minY) / height);
    }).toList();

    // Find the turning point (where direction changes from down-right to up-right)
    int turningPointIndex = -1;
    double lowestY = 0.0;

    for (int i = 0; i < normalized.length; i++) {
      if (normalized[i].dy > lowestY) {
        lowestY = normalized[i].dy;
        turningPointIndex = i;
      }
    }

    if (turningPointIndex < 2 || turningPointIndex > normalized.length - 3) {
      return 0.0; // Turning point should be in the middle portion
    }

    // Split into two segments: before and after turning point
    final firstSegment = normalized.sublist(0, turningPointIndex + 1);
    final secondSegment = normalized.sublist(turningPointIndex);

    // Check first segment: should go down and slightly right
    double firstSegmentScore = 0.0;
    if (firstSegment.length >= 2) {
      final firstStart = firstSegment.first;
      final firstEnd = firstSegment.last;

      // Should move downward (positive Y)
      final downwardMovement = firstEnd.dy - firstStart.dy;

      // Should move right but not too much
      final rightwardMovement = firstEnd.dx - firstStart.dx;

      if (downwardMovement > 0.2 &&
          rightwardMovement >= -0.1 &&
          rightwardMovement <= 0.4) {
        firstSegmentScore = 0.5;
      }
    }

    // Check second segment: should go up and to the right
    double secondSegmentScore = 0.0;
    if (secondSegment.length >= 2) {
      final secondStart = secondSegment.first;
      final secondEnd = secondSegment.last;

      // Should move upward (negative Y change)
      final upwardMovement = secondStart.dy - secondEnd.dy;

      // Should move significantly to the right
      final rightwardMovement = secondEnd.dx - secondStart.dx;

      if (upwardMovement > 0.1 && rightwardMovement > 0.2) {
        secondSegmentScore = 0.5;
      }
    }

    // Check aspect ratio (checkmarks are typically wider than tall or roughly square)
    double aspectScore = 0.0;
    final aspectRatio = width / height;
    if (aspectRatio >= 0.7 && aspectRatio <= 2.0) {
      aspectScore = 0.2;
    }

    // Check that the turning point is in the left-center area
    double turningPositionScore = 0.0;
    final turningX = normalized[turningPointIndex].dx;
    if (turningX >= 0.2 && turningX <= 0.5) {
      turningPositionScore = 0.3;
    }

    // Calculate total confidence
    final totalScore =
        firstSegmentScore +
        secondSegmentScore +
        aspectScore +
        turningPositionScore;

    // Normalize to 0-1 range (max possible score is 1.5)
    return (totalScore / 1.5).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    initRive();
  }

  void initRive() async {
    file = (await File.asset(
      "assets/create_account.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = RiveWidgetController(file);
    final vmi = controller.dataBind(DataBind.auto());
    _openDraw = vmi.trigger('open_draw');
    _openImport = vmi.trigger('open_import');

    setState(() => isInitialized = true);

    // Let the intro animation play, then trigger draw state with fade
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _openDraw!.trigger();
        setState(() {
          isShowingIntro = false;
          isDrawingCheckmark = true;
        });
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _phoneController.dispose();
    file.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF7BA7E1),
      body: Stack(
        children: [
          // Background color fallback
          Positioned.fill(
            child: Container(color: const Color(0xFF7BA7E1)),
          ),
          // Rive animation in the background (stays fixed)
          Positioned.fill(
            child: RiveWidget(controller: controller, fit: Fit.fitWidth),
          ),
          // Content overlay - hidden during intro animation
          if (!isShowingIntro)
            FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      // Title text - changes based on state
                      Text(
                        isImportScreen
                            ? "Let's Import\nYour Group Chat"
                            : "Your Privacy\nMatters.",
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Subtitle text - changes based on state
                      Text(
                        isImportScreen
                            ? "We support WhatsApp only."
                            : "We prioritize your privacy. Nothing is stored, uploaded, or saved. All data and insights vanish the moment you close the app.\n\nDraw a checkmark to continue:",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Phone input field - only shown initially
                      if (isCreateAccountButtonVisible)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B9BD8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              // Country code picker
                              CountryCodePicker(
                                onChanged: (countryCode) {
                                  print(countryCode);
                                },
                                initialSelection: 'US',
                                favorite: const ['+1', 'US'],
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                dialogTextStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                flagWidth: 28,
                                backgroundColor: const Color(0xFF6B9BD8),
                                dialogBackgroundColor: Colors.white,
                                barrierColor: Colors.black54,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '(650) 213-7390',
                                    hintStyle: TextStyle(
                                      color: Color(0xFFB8D4F0),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Color(0xFFB8D4F0),
                                  size: 20,
                                ),
                                onPressed: () {
                                  _phoneController.clear();
                                },
                              ),
                            ],
                          ),
                        ),
                      // Drawing area - shown after create account button click
                      if (isDrawingCheckmark && !isImportScreen)
                        GestureDetector(
                          onPanStart: (details) {
                            setState(() {
                              _drawingPoints.add(details.localPosition);
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _drawingPoints.add(details.localPosition);
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              _drawingPoints.add(Offset.infinite);
                            });

                            // Check if the drawing matches a checkmark
                            final matchScore = checkCheckmarkMatch(
                              _drawingPoints,
                            );
                            debugPrint('Checkmark match score: $matchScore');

                            // Require at least 60% match to proceed
                            if (matchScore >= 0.6) {
                              // Trigger import animation after successful checkmark
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  if (!mounted) return;
                                  _openImport!.trigger();
                                  setState(() {
                                    isImportScreen = true;
                                  });
                                },
                              );
                            } else {
                              // Clear the drawing and let user try again
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  if (!mounted) return;
                                  setState(() {
                                    _drawingPoints.clear();
                                  });
                                  // Optionally show a message to user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please draw a checkmark to continue',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: const Color(0xFF6B9BD8),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B9BD8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CustomPaint(
                                painter: DrawingPainter(_drawingPoints),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                        ),
                      const Spacer(),
                      // Create Account button - moves up with keyboard
                      if (isCreateAccountButtonVisible)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: bottomInset > 0 ? bottomInset + 16 : 40,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(
                                  context,
                                ).unfocus(); // Dismiss keyboard
                                setState(() {
                                  isCreateAccountButtonVisible = false;
                                  isDrawingCheckmark = true;
                                });
                                _openDraw!.trigger();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Show Me How button - shown on import screen
                      if (isImportScreen)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle show me how action
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        TutorialPage(),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        )),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 400),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Show Me How',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF9CCC65) // Green color like in the screenshot
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
