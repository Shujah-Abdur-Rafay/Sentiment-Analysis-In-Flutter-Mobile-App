import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vocal_emotion/utils/animations.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/view/BottomNavBar/BottomNavBar.dart';
import 'package:vocal_emotion/widgets/futuristic_components.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  late AnimationController _animationController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });

    _passwordFocusNode.addListener(() {
      setState(() {});
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields."),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in the user
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String username = userDoc['username'];

        // Show welcome message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome back, $username!"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBarScreen()),
          (route) => false, // This removes all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User data not found."),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.toString()}"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated particle background
          CustomPaint(
            painter: ParticlePainter(
              controller: _animationController,
              particleColor: AppColors.secondary.withOpacity(0.4),
              particleCount: 40,
            ),
            child: const SizedBox.expand(),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    // Back button
                    SlideInAnimation(
                      beginOffset: const Offset(-30, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary,
                            size: 20.w,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Animated logo
                    Center(
                      child: FadeInAnimation(
                        child: Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.mic,
                              size: 50.w,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Welcome text
                    Center(
                      child: SlideInAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            GlitchText(
                              text: 'WELCOME BACK',
                              style: TextStyle(
                                fontSize: 28.sp,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontFamily: 'Kodchasan',
                              ),
                              isActive: false,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Sign in to continue your voice analysis journey',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 50.h),

                    // Email input
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 300),
                      beginOffset: const Offset(0, 30),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FuturisticTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          focusNode: _emailFocusNode,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Password input
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 400),
                      beginOffset: const Offset(0, 30),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FuturisticTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          focusNode: _passwordFocusNode,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          isPassword: true,
                          onSuffixIconPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: FadeInAnimation(
                        delay: const Duration(milliseconds: 500),
                        child: GestureDetector(
                          onTap: () {
                            // Handle forgot password
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 50.h),

                    // Login button
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 600),
                      beginOffset: const Offset(0, 30),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? Center(
                                child: ShimmerLoading(
                                  baseColor: AppColors.primary.withOpacity(0.2),
                                  highlightColor:
                                      AppColors.primary.withOpacity(0.6),
                                  child: NeonButton(
                                    text: 'LOGGING IN...',
                                    glowColor: AppColors.primary,
                                    width: MediaQuery.of(context).size.width,
                                    onPressed: () {},
                                    isPulsing: false,
                                  ),
                                ),
                              )
                            : NeonButton(
                                text: 'LOGIN',
                                glowColor: AppColors.primary,
                                width: MediaQuery.of(context).size.width,
                                onPressed: _login,
                              ),
                      ),
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String asset, Color color) {
    return GestureDetector(
      onTap: () {
        // Social login functionality
      },
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: SvgPicture.asset(
            asset,
            colorFilter: ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
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
