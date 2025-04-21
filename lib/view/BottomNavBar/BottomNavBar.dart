import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/view/AboutScreen/about.dart';
import 'package:vocal_emotion/view/HomeScreen.dart/homescreen.dart';
import 'package:vocal_emotion/view/UserRecordsScreen/BottoTab2.dart';
import 'package:vocal_emotion/utils/animations.dart';
import 'dart:ui';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  // Variables to handle double-tap to exit
  DateTime? _lastBackPressTime;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EveryThings(),
    const AboutScreen(),
  ];

  final List<String> _titles = ["Home", "Records", "About"];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.mic_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers for tab indicators
    _animationControllers = List.generate(
      _screens.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    // Initialize animations
    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );
    }).toList();

    // Start animation for the initial selected tab
    _animationControllers[_selectedIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      // Reset previous animation and start new one
      _animationControllers[_selectedIndex].reverse();
      _selectedIndex = index;
      _animationControllers[_selectedIndex].forward();
    });
  }

  // Handle back button press with confirmation
  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      // First press or more than 2 seconds since last press
      _lastBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface,
        ),
      );

      return false; // Don't exit the app yet
    }

    // Exit the app on second press within 2 seconds
    await SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor:
            themeProvider.isDarkMode ? AppColors.background : Colors.white,
        body: Stack(
          children: [
            // Screen content
            _screens[_selectedIndex],

            // Bottom navigation bar
            Positioned(
              bottom: 15.h,
              left: 20.w,
              right: 20.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10.0,
                    sigmaY: 10.0,
                  ),
                  child: Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? AppColors.surface.withOpacity(0.8)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        _screens.length,
                        (index) => _buildNavItem(index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 85.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  height: 50.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _icons[index],
                      color: isSelected
                          ? AppColors.primary
                          : themeProvider.isDarkMode
                              ? AppColors.textSecondary
                              : Colors.grey,
                      size: 28.sp *
                          (isSelected
                              ? 1 + (_animations[index].value * 0.2)
                              : 1),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 5.w : 0,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
