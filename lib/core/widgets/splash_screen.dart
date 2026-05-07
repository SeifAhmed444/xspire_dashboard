import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// dart:async is not required here
import 'package:xspire_dashboard/core/localization/app_localizations.dart';

class SplashWrapper extends StatelessWidget {
  final String initialRoute;
  final Duration duration;
  final Widget child;

  const SplashWrapper({
    super.key,
    required this.initialRoute,
    this.duration = const Duration(milliseconds: 4000),
    this.child = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return AppSplashScreen(
      initialRoute: initialRoute,
      duration: duration,
      child: child,
    );
  }
}

class AppSplashScreen extends StatefulWidget {
  final Duration duration;
  final String initialRoute;
  final Widget child;

  const AppSplashScreen({
    super.key,
    required this.initialRoute,
    this.duration = const Duration(milliseconds: 4000),
    required this.child,
  });

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Fade out in the final 25% of the duration
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    // Slight scale for subtle motion
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(widget.initialRoute);
        }
      }
    });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)?.appTitle ?? 'XSpire Dashboard';

    return Stack(
      children: [
        // App content underneath
        Positioned.fill(child: widget.child),

        // Splash overlay which fades out
        Positioned.fill(
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fade),
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Background gradient SVG
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'assets/splash/splash_bg.svg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Centered icon + title with slight scale
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _scale,
                      builder: (context, child) =>
                          Transform.scale(scale: _scale.value, child: child),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.25),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/icons/icon3.PNG',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
