// custom_page_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/utils/colors.dart';

class CustomPageView extends StatefulWidget {
  const CustomPageView({super.key});

  @override
  _CustomPageViewState createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  int _currentPage = 0;
  final List<String> _images = [
    'assets/new1.jpg',
    'assets/new5.jpg',
    'assets/new2.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      height: 144.h,
      width: 361.w,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? AppColors.darkblack
            : AppColors.whitecolor,
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: PageView.builder(
              itemCount: _images.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset(
                      _images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 8.h,
                  width: _currentPage == index ? 20.w : 8.w,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.whitecolor
                        : AppColors.textfieldheading,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
