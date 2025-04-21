import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocal_emotion/Auth/login_screen.dart';
import 'package:vocal_emotion/Auth/signup_screen.dart';
import 'package:vocal_emotion/utils/animations.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/widgets/futuristic_components.dart';
import 'dart:math' as math;

class OptionScreen extends StatefulWidget {
  const OptionScreen({super.key});

  @override
  _OptionScreenState createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _showContent = false;

  // Updated with more professional voice analysis images
  final List<Map<String, dynamic>> _pageData = [
    {
      'image': 'assets/voice_analysis1.jpg', // Replace with actual asset
      'title': 'Voice Emotion Analysis',
      'description':
          'Discover the emotions behind speech with our AI-powered technology',
    },
    {
      'image': 'assets/voice_analysis2.jpg', // Replace with actual asset
      'title': 'Real-time Insights',
      'description':
          'Get instant emotional analysis to understand communication better',
    },
    {
      'image': 'assets/voice_analysis3.jpg', // Replace with actual asset
      'title': 'Professional Applications',
      'description': 'Enhance communication skills and emotional intelligence',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Trigger content animations after a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showContent = true);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background with particle effect
          CustomPaint(
            painter: ParticlePainter(
              controller: _animationController,
              particleColor: AppColors.primary.withOpacity(0.4),
              particleCount: 60,
            ),
            child: const SizedBox.expand(),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                SlideInAnimation(
                  beginOffset: const Offset(0, -30),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mic,
                            color: AppColors.primary,
                            size: 24.w,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'VOCAL EMOTION',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Image carousel with glassmorphic effect
                Expanded(
                  flex: 6,
                  child: FadeInAnimation(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: Stack(
                          children: [
                            // Image slider
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              itemCount: _pageData.length,
                              itemBuilder: (context, index) {
                                // Placeholder images until real ones are added
                                Color gradientStart;
                                Color gradientEnd;
                                IconData iconData;

                                // Set different color schemes for each slide
                                switch (index) {
                                  case 0:
                                    gradientStart =
                                        AppColors.primary.withOpacity(0.8);
                                    gradientEnd =
                                        AppColors.background.withOpacity(0.95);
                                    iconData = Icons.mic_rounded;
                                    break;
                                  case 1:
                                    gradientStart =
                                        AppColors.secondary.withOpacity(0.8);
                                    gradientEnd =
                                        AppColors.background.withOpacity(0.95);
                                    iconData = Icons.equalizer_rounded;
                                    break;
                                  case 2:
                                    gradientStart =
                                        AppColors.tertiary.withOpacity(0.8);
                                    gradientEnd =
                                        AppColors.background.withOpacity(0.95);
                                    iconData = Icons.psychology_outlined;
                                    break;
                                  default:
                                    gradientStart =
                                        AppColors.primary.withOpacity(0.8);
                                    gradientEnd =
                                        AppColors.background.withOpacity(0.95);
                                    iconData = Icons.mic_rounded;
                                }

                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Gradient background as placeholder for images
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            gradientStart,
                                            gradientEnd,
                                          ],
                                          stops: const [0.3, 1.0],
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Larger icon in background
                                          Positioned(
                                            right: -30.w,
                                            bottom: 50.h,
                                            child: Icon(
                                              iconData,
                                              size: 180.sp,
                                              color: AppColors.textPrimary
                                                  .withOpacity(0.05),
                                            ),
                                          ),
                                          // Smaller centered icon
                                          Center(
                                            child: Container(
                                              padding: EdgeInsets.all(18.w),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    gradientStart,
                                                    gradientStart
                                                        .withOpacity(0.3),
                                                  ],
                                                  stops: const [0.3, 1.0],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: gradientStart
                                                        .withOpacity(0.5),
                                                    blurRadius: 20,
                                                    spreadRadius: 5,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                iconData,
                                                size: 60.sp,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Content overlay
                                    Positioned(
                                      bottom: 40.h,
                                      left: 20.w,
                                      right: 20.w,
                                      child: GlassmorphicCard(
                                        height: 120.h,
                                        borderRadius: 15,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.w, vertical: 12.h),
                                        borderColor:
                                            AppColors.primary.withOpacity(0.3),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.1),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _pageData[index]['title'],
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 10.h),
                                            Text(
                                              _pageData[index]['description'],
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14.sp,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            // Page indicator
                            Positioned(
                              bottom: 15.h,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _pageData.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 3.w),
                                    width: _currentPage == index ? 24.w : 8.w,
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      color: _currentPage == index
                                          ? AppColors.primary
                                          : AppColors.textSecondary
                                              .withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(2.r),
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
                ),

                SizedBox(height: 30.h),

                // Title with animation
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _showContent ? 1.0 : 0.0,
                  child: GlitchText(
                    text: 'NEXT-GEN VOICE ANALYSIS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    isActive: _showContent,
                  ),
                ),

                SizedBox(height: 10.h),

                // Description with animation
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _showContent ? 1.0 : 0.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Text(
                      'Unlock the power of vocal emotion detection with cutting-edge AI technology',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // Buttons with animation - Made larger and more prominent
                SlideInAnimation(
                  delay: const Duration(milliseconds: 300),
                  beginOffset: const Offset(0, 30),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: 'LOGIN',
                            glowColor: AppColors.primary,
                            height: 56.h,
                            onPressed: _navigateToLogin,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: NeonButton(
                            text: 'SIGNUP',
                            glowColor: AppColors.secondary,
                            height: 56.h,
                            onPressed: _navigateToSignup,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Removed social login buttons
                SizedBox(height: 30.h),
              ],
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
