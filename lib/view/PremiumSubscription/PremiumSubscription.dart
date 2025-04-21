import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocal_emotion/utils/colors.dart';

class PremiumSubscription extends StatelessWidget {
  const PremiumSubscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 237, 237),
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
        border: Border.all(color: AppColors.movingcolor, width: 2),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSubscriptionDetails()),
          SizedBox(width: 10.w),
          _buildSubscriptionImage(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Premium Subscription',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 5.h),
        Text('Unlock exclusive features to enhance your experience, including:',
            style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
        SizedBox(height: 5.h),
        ..._buildSubscriptionFeatures(),
      ],
    );
  }

  List<Widget> _buildSubscriptionFeatures() {
    const features = [
      '- Access to advanced emotion detection algorithms.',
      '- Priority support for your queries and issues.',
      '- Personalized insights and recommendations.',
    ];
    return features
        .map((feature) => Text(feature,
            style: TextStyle(color: Colors.grey, fontSize: 14.sp)))
        .toList();
  }

  Widget _buildSubscriptionImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Image.asset(
        'assets/coin.png',
        fit: BoxFit.cover,
        height: 100.h,
        width: 100.w,
      ),
    );
  }
}
