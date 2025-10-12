import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<CreateAccount> {
  late File file;
  late RiveWidgetController controller;
  bool isInitialized = false;
  ViewModelInstanceTrigger? _openDraw;
  ViewModelInstanceTrigger? _openImport;
  bool isCreateAccountButtonVisible = true;
  bool isDrawingCheckmark = false;
  bool isImportScreen = false;
  final TextEditingController _phoneController = TextEditingController();
  final List<Offset> _drawingPoints = [];

  @override
  void initState() {
    super.initState();
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

    // controller.advance(0);
    // await Future.delayed(Duration(seconds: 2));
    // controller = RiveWidgetController(
    //   file,
    //   stateMachineSelector: StateMachineSelector.byName("State Machine"),
    // );
    // setState(() {});
  }

  @override
  void dispose() {
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
          // Rive animation in the background (stays fixed)
          Positioned.fill(
            child: RiveWidget(controller: controller, fit: Fit.cover),
          ),
          // Content overlay
          SafeArea(
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
                        : (isDrawingCheckmark
                              ? "Your Privacy\nMatters."
                              : "Let's Get\nStarted!"),
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
                        : (isDrawingCheckmark
                              ? "If you love privacy & security, please\ndraw a checkmark here:"
                              : "Enter your phone number. We will\nsend you a confirmation code there."),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                                hintStyle: TextStyle(color: Color(0xFFB8D4F0)),
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
                        // Trigger import animation after drawing
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _openImport!.trigger();
                          setState(() {
                            isImportScreen = true;
                          });
                        });
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
                      child: Container(
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle show me how action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
