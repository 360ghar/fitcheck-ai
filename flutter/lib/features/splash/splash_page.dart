import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../auth/controllers/auth_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const String _titleText = 'FitCheckAI';
  late final AnimationController _controller;
  late final List<Animation<double>> _letterAnimations;
  late final Animation<double> _cursorAnimation;

  @override
  void initState() {
    super.initState();

    // Total duration: 2.5 seconds for all letters to appear
    const totalDuration = Duration(milliseconds: 2500);
    const staggerDelay = Duration(milliseconds: 150); // Delay between each letter

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    // Create individual animations for each letter with staggered delays
    _letterAnimations = List.generate(
      _titleText.length,
      (index) {
        final delay = index * staggerDelay.inMilliseconds;
        final startTime = delay / totalDuration.inMilliseconds;
        final endTime = ((delay + staggerDelay.inMilliseconds * 2) / totalDuration.inMilliseconds).clamp(0.0, 1.0);

        return TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: 0.0),
            weight: startTime.clamp(0.001, 1.0),
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
            weight: (endTime - startTime).clamp(0.001, 1.0),
          ),
          TweenSequenceItem(
            tween: ConstantTween(1.0),
            weight: (1.0 - endTime).clamp(0.001, 1.0),
          ),
        ]).animate(_controller);
      },
    );

    // Cursor blinking animation
    _cursorAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final authController = Get.find<AuthController>();
    const minSplashDuration = Duration(milliseconds: 900);
    await Future.wait([
      authController.initializeAuth(),
      Future.delayed(minSplashDuration),
    ]);

    if (!mounted) return;

    if (authController.isAuthenticated) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA);
    final primaryColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryColor = isDarkMode
        ? const Color(0xFF6366F1)  // Indigo for dark mode
        : const Color(0xFF6366F1); // Indigo for light mode
    final accentColor = isDarkMode
        ? const Color(0xFFEC4899)  // Pink for dark mode
        : const Color(0xFFF43F5E); // Rose for light mode

    final overlayStyle = isDarkMode
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    final styledOverlay = overlayStyle.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: backgroundColor,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: styledOverlay,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated letters
                  ...List.generate(_titleText.length, (index) {
                    final letter = _titleText[index];
                    final animation = _letterAnimations[index];

                    return _AnimatedLetter(
                      letter: letter,
                      animation: animation,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                      accentColor: accentColor,
                      index: index,
                    );
                  }),

                  // Typing cursor
                  _buildCursor(_cursorAnimation, accentColor),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCursor(Animation<double> animation, Color color) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = (animation.value * 0.5 + 0.5).clamp(0.0, 1.0);
        return Container(
          width: 3,
          height: 48,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

class _AnimatedLetter extends StatelessWidget {
  final String letter;
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final int index;

  const _AnimatedLetter({
    required this.letter,
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = animation.value;
        final opacity = animation.value.clamp(0.0, 1.0);

        // Use accent color for special letters (F, C, A)
        final isAccentLetter = letter == 'F' && index == 0 ||
                               letter == 'C' && index == 5 ||
                               letter == 'A' && index == 9;

        final letterColor = isAccentLetter ? accentColor : primaryColor;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: letterColor,
                  letterSpacing: 0,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: letterColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
