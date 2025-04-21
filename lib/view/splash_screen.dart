import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocal_emotion/utils/animations.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/view/choice_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showText = false;
  bool _showWaves = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _animateElements();
    _navigateToHome();
  }

  _animateElements() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _showText = true);
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _showWaves = true);
    }
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OptionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.easeOutCubic;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          AnimatedGradientBackground(
            colorSets: [
              [
                AppColors.background,
                Colors.black.withBlue(30),
                AppColors.primaryVariant.withOpacity(0.4)
              ],
              [
                AppColors.background,
                Colors.black.withBlue(20),
                AppColors.primary.withOpacity(0.3)
              ],
            ],
            duration: const Duration(seconds: 8),
            child: const SizedBox.expand(),
          ),

          // Particle effect
          CustomPaint(
            painter: ParticlePainter(
              controller: _controller,
              particleColor: AppColors.primary.withOpacity(0.6),
            ),
            child: Container(),
          ),

          // Logo animation
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: 1.0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: const [
                            AppColors.primary,
                            AppColors.secondary,
                            AppColors.accent,
                            AppColors.primary,
                          ],
                          transform:
                              GradientRotation(_controller.value * 2 * math.pi),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.mic,
                              size: 60.w,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Text animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            bottom: _showText ? 150.h : 100.h,
            left: 0,
            right: 0,
            curve: Curves.easeOutQuad,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _showText ? 1.0 : 0.0,
              child: Center(
                child: Column(
                  children: [
                    GlitchText(
                      text: 'EMOTION DETECTION',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      isActive: _showText,
                    ),
                    SizedBox(height: 8.h),
                    FadeInAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'through speech analysis',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Wave animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            bottom: _showWaves ? 60.h : 0.h,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _showWaves ? 1.0 : 0.0,
              child: const Center(
                child: WaveAnimation(
                  count: 20,
                  height: 40,
                  color: AppColors.primary,
                  spacing: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Particle effect painter
class ParticlePainter extends CustomPainter {
  final AnimationController controller;
  final Color particleColor;
  final int particleCount;

  final List<Particle> particles = [];

  ParticlePainter({
    required this.controller,
    this.particleColor = Colors.white,
    this.particleCount = 40,
  }) : super(repaint: controller) {
    // Initialize particles
    for (int i = 0; i < particleCount; i++) {
      particles.add(Particle());
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particleCount; i++) {
      // Update particle position based on animation value
      Particle particle = particles[i];

      // Calculate position based on time
      double x = particle.initialX +
          (particle.speedX * controller.value * 10) % size.width;
      double y = particle.initialY +
          (particle.speedY * controller.value * 10) % size.height;

      // Wrap around screen
      if (x > size.width) x = 0;
      if (y > size.height) y = 0;
      if (x < 0) x = size.width;
      if (y < 0) y = size.height;

      // Update particle internal position
      particle.x = x;
      particle.y = y;

      // Draw particle
      Paint paint = Paint()
        ..color = particleColor.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size, paint);

      // Draw connections between nearby particles
      for (int j = i + 1; j < particleCount; j++) {
        Particle other = particles[j];
        double distance = _calculateDistance(particle, other);
        if (distance < 150) {
          // Max distance for connection
          double opacity = (1 - distance / 150) * 0.2; // Fade out with distance
          Paint linePaint = Paint()
            ..color = particleColor.withOpacity(opacity)
            ..strokeWidth = 0.8;

          canvas.drawLine(Offset(particle.x, particle.y),
              Offset(other.x, other.y), linePaint);
        }
      }
    }
  }

  double _calculateDistance(Particle a, Particle b) {
    return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  double x = 0;
  double y = 0;
  late double initialX;
  late double initialY;
  late double size;
  late double opacity;
  late double speedX;
  late double speedY;

  Particle() {
    // Initial random position
    initialX = x = math.Random().nextDouble() * 400;
    initialY = y = math.Random().nextDouble() * 800;

    // Random size
    size = math.Random().nextDouble() * 2 + 0.5;

    // Random opacity
    opacity = math.Random().nextDouble() * 0.5 + 0.1;

    // Random speed
    speedX = (math.Random().nextDouble() - 0.5) * 2;
    speedY = (math.Random().nextDouble() - 0.5) * 2;
  }
}
