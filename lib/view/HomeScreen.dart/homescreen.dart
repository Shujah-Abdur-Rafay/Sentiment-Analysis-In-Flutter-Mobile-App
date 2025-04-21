import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/UserProvider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/utils/animations.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/view/AudioFilePicker/pick_audio.dart';
import 'package:vocal_emotion/view/PremiumSubscription/PremiumSubscription.dart';
import 'package:vocal_emotion/widgets/futuristic_components.dart';
import 'package:vocal_emotion/widgets/page_view.dart'; // Import for CustomPageView
import 'package:vocal_emotion/screens/voice_recorder_screen.dart'; // Import for VoiceRecorderScreen
import 'dart:ui';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isImageLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch user data when the screen initializes
    Provider.of<UserProvider>(context, listen: false).fetchUserData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background particle effect
          CustomPaint(
            painter: ParticlePainter(
              controller: _animationController,
              particleColor: AppColors.primary.withOpacity(0.3),
              particleCount: 30,
            ),
            child: const SizedBox.expand(),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user info
                  _buildHeader(currentUser),

                  SizedBox(height: 20.h),

                  // Feature cards carousel
                  SlideInAnimation(
                    beginOffset: const Offset(0, 30),
                    child: _buildFeatureCarousel(),
                  ),

                  SizedBox(height: 25.h),

                  // Title
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'VOICE ANALYSIS TOOLS',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // Action cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        // Record audio card
                        Expanded(
                          child: SlideInAnimation(
                            delay: const Duration(milliseconds: 400),
                            beginOffset: const Offset(-30, 0),
                            child: _buildActionCard(
                              title: 'Record Audio',
                              gradient: AppColors.blueGradient,
                              icon: Icons.mic_rounded,
                              onTap: () {
                                // Navigate to voice recorder screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const VoiceRecorderScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        // Pick audio card
                        Expanded(
                          child: SlideInAnimation(
                            delay: const Duration(milliseconds: 500),
                            beginOffset: const Offset(30, 0),
                            child: _buildActionCard(
                              title: 'Pick Audio',
                              gradient: AppColors.cyberpunkGradient,
                              icon: Icons.audio_file_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChooseAudioScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25.h),

                  // Premium subscription
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 600),
                    beginOffset: const Offset(0, 30),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: const PremiumSubscription(),
                    ),
                  ),

                  SizedBox(height: 25.h),

                  // Recent emotions section
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 700),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RECENT ANALYSIS',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          _buildEmotionChart(),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 100.h), // Extra space for bottom nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header with user info and welcome message
  Widget _buildHeader(currentUser) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primaryVariant.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Welcome text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Kodchasan',
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SlideInAnimation(
                    beginOffset: const Offset(-20, 0),
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      children: [
                        Text(
                          currentUser?.username ?? 'Guest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kodchasan',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'Ready to analyze your emotions?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // User avatar
              SlideInAnimation(
                beginOffset: const Offset(20, 0),
                delay: const Duration(milliseconds: 200),
                child: AnimatedBorderAvatar(
                  imageUrl: currentUser?.imageUrl ?? '',
                  size: 60.w, // Fixed size value
                  borderColors: const [
                    Colors.white,
                    AppColors.secondary,
                    Colors.white,
                    AppColors.accent,
                  ],
                  placeholderWidget: Icon(
                    Icons.person,
                    size: 30.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          // Quick stats section
          FadeInAnimation(
            delay: const Duration(milliseconds: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.equalizer_rounded,
                  label: 'Analyses',
                  value: '12',
                ),
                _buildStatItem(
                  icon: Icons.emoji_emotions_rounded,
                  label: 'Emotions',
                  value: '5',
                ),
                _buildStatItem(
                  icon: Icons.audio_file_rounded,
                  label: 'Recordings',
                  value: '8',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stat item widget for the header
  Widget _buildStatItem(
      {required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  // Feature carousel with glassmorphic cards
  Widget _buildFeatureCarousel() {
    return SizedBox(
      height: 180.h,
      child: const CustomPageView(),
    );
  }

  // Action card for record and pick audio
  Widget _buildActionCard({
    required String title,
    required List<Color> gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: PulseAnimation(
        minScale: 0.97,
        maxScale: 1.0,
        repeat: false,
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20.w,
                bottom: -20.h,
                child: Icon(
                  icon,
                  size: 100.sp,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Emotion chart with mock data
  Widget _buildEmotionChart() {
    final emotions = {
      'Happy': 0.65,
      'Neutral': 0.85,
      'Sad': 0.35,
      'Angry': 0.25,
      'Surprised': 0.55,
    };

    return GlassmorphicCard(
      height: 200.h,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surfaceLight.withOpacity(0.5),
          AppColors.surfaceLight.withOpacity(0.2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emotion Distribution',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: emotions.length,
              itemBuilder: (context, index) {
                final emotion = emotions.keys.elementAt(index);
                final value = emotions[emotion]!;

                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            emotion,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '${(value * 100).toInt()}%',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Stack(
                        children: [
                          // Background bar
                          Container(
                            height: 8.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          // Progress bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1500),
                            height: 8.h,
                            width:
                                MediaQuery.of(context).size.width * 0.8 * value,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getGradientForEmotion(emotion),
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                              boxShadow: [
                                BoxShadow(
                                  color: _getGradientForEmotion(emotion)
                                      .first
                                      .withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Get gradient colors based on emotion type
  List<Color> _getGradientForEmotion(String emotion) {
    switch (emotion) {
      case 'Happy':
        return [Colors.yellow, Colors.amber];
      case 'Sad':
        return [Colors.blue.shade300, Colors.blue.shade600];
      case 'Angry':
        return [Colors.red.shade400, Colors.red.shade700];
      case 'Surprised':
        return [Colors.purple.shade300, Colors.purple.shade700];
      case 'Neutral':
      default:
        return [Colors.green.shade300, Colors.green.shade600];
    }
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
    return (a.x - b.x).abs() +
        (a.y - b.y).abs(); // Manhattan distance for efficiency
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
