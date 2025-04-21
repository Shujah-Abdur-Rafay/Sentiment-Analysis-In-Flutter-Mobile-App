import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG support

class GradientContainer extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final VoidCallback onTap;
  final String iconPath; // Path to the SVG icon

  const GradientContainer({
    super.key,
    required this.title,
    required this.colors,
    required this.onTap,
    required this.iconPath, // Add iconPath parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
        width: 150.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          gradient: LinearGradient(
            colors: colors,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 34.h,
              width: 34.w,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
