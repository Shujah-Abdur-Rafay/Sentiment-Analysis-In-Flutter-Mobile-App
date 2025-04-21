import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/utils/colors.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  // Sample data for demonstration
  final List<String> audioFiles = [
    'Drive Mental Health Support',
    'Mindfulness Meditation',
    'Stress Relief Audio',
    'Focus Music',
    'Sleep Aid Soundtrack',
  ];

  // Corresponding emotions for each audio file
  final List<String> emotions = [
    'Happy',
    'Calm',
    'Relaxed',
    'Focused',
    'Sleepy',
  ];

  // Corresponding colors for each emotion
  final List<Color> emotionColors = [
    Colors.green, // Happy
    Colors.blue, // Calm
    Colors.orange, // Relaxed
    Colors.purple, // Focused
    Colors.blueGrey, // Sleepy
  ];

  // Corresponding date and time for each audio file
  final List<String> dateTimes = [
    '2024-10-01 10:00 AM',
    '2024-10-02 2:30 PM',
    '2024-10-03 4:15 PM',
    '2024-10-04 9:00 AM',
    '2024-10-05 11:45 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? AppColors.darkblack : AppColors.homescreen,
      body: Column(
        children: [
          SizedBox(
            height: 10.h,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: audioFiles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Container(
                    height:
                        120.h, // Adjusted height to accommodate date and time
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                        bottom: 10.h), // Spacing between containers
                    decoration: BoxDecoration(
                      color: emotionColors[index], // Color based on emotion
                      borderRadius: BorderRadius.all(
                        Radius.circular(16.r),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.h),
                        Text(
                          audioFiles[index],
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 14.sp,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Emotions: ',
                                        style: TextStyle(
                                          color: Colors.white, // Text color
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      TextSpan(
                                        text: emotions[index],
                                        style: TextStyle(
                                          color: Colors
                                              .white, // Text color for emotion
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 24.sp,
                                ),
                                onPressed: () {
                                  // Handle delete action
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5.h), // Spacing for better layout
                        Text(
                          dateTimes[index],
                          style: TextStyle(
                            color: Colors.white, // Date and time text color
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
