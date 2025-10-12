import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:country_code_picker/country_code_picker.dart';

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
  bool isCreateAccountButtonVisible=true;
  final TextEditingController _phoneController = TextEditingController();

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF7BA7E1),
      body: Stack(
        children: [
          // Rive animation in the background
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
                  // Title text
                  const Text(
                    "Let's Get\nStarted!",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle text
                  const Text(
                    "Enter your phone number. We will\nsend you a confirmation code there.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Phone input field
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
                          dialogTextStyle: const TextStyle(color: Colors.black),
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
                  const Spacer(),
                  // Create Account button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 40),
                    child: ElevatedButton(
                      onPressed: () {
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
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
