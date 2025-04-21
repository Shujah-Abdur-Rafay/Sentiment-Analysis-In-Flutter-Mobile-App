import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const CustomTab({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
