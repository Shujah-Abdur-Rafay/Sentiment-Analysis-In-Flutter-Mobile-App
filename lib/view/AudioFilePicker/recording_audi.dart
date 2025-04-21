// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:record/record.dart';
// import 'package:vocal_emotion/Provider/theme_provider.dart';
// import 'package:vocal_emotion/utils/colors.dart';
// import 'package:permission_handler/permission_handler.dart';

// class RecordAudioScreen extends StatefulWidget {
//   const RecordAudioScreen({super.key});

//   @override
//   _RecordAudioScreenState createState() => _RecordAudioScreenState();
// }

// class _RecordAudioScreenState extends State<RecordAudioScreen> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final Record _record = Record(); // Create an instance of Record
//   bool _isRecording = false;
//   String? _recordedFilePath;

//   Future<void> _checkPermissions() async {
//     // Check microphone permission
//     final status = await Permission.microphone.request();
//     if (status.isDenied) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("Microphone permission is required to record audio")),
//       );
//       return; // Exit if permission is denied
//     }
//   }

//   Future<void> _toggleRecording() async {
//     await _checkPermissions(); // Check permissions before proceeding

//     if (_isRecording) {
//       // Stop recording
//       await _record.stop(); // Stop recording using the instance
//       setState(() {
//         _isRecording = false;
//       });
//     } else {
//       // Start recording
//       final Directory directory = await Directory.systemTemp.createTemp();
//       _recordedFilePath = '${directory.path}/recorded_audio.m4a';

//       // Start the recording
//       final result = await _record.start(
//         path: _recordedFilePath,
//         encoder: AudioEncoder.aacLc,
//       );

//       if (result) {
//         setState(() {
//           _isRecording = true;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to start recording")),
//         );
//       }
//     }
//   }

//   void _playAudio() async {
//     if (_recordedFilePath != null) {
//       // Use FileSource for local file path
//       await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//     return Scaffold(
//       backgroundColor:
//           themeProvider.isDarkMode ? AppColors.darkblack : AppColors.homescreen,
//       appBar: AppBar(
//         backgroundColor: themeProvider.isDarkMode
//             ? AppColors.whitecolor
//             : AppColors.darkblack,
//         title: Text(
//           'Choose Audio File',
//           style: TextStyle(
//             color: AppColors.whitecolor,
//             fontSize: 19.sp,
//           ),
//         ),
//         iconTheme: const IconThemeData(
//           color: AppColors.whitecolor,
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 10.w),
//         child: Column(
//           children: [
//             SizedBox(height: 50.h),
//             Text(
//               'Record your audio for submission to model',
//               style: TextStyle(
//                 color: themeProvider.isDarkMode
//                     ? AppColors.whitecolor
//                     : AppColors.textfieldheading,
//                 fontSize: 15.sp,
//               ),
//             ),
//             SizedBox(height: 50.h),
//             GestureDetector(
//               onTap: _toggleRecording,
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: themeProvider.isDarkMode
//                       ? AppColors.darkblack
//                       : AppColors.whitecolor,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.red, width: 2),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       _isRecording ? Icons.stop : Icons.mic,
//                       size: 40,
//                       color: Colors.black,
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       _isRecording ? 'Recording...' : 'Tap to Record',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 50.h),
//             if (_recordedFilePath != null) ...[
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: themeProvider.isDarkMode
//                       ? AppColors.darkblack
//                       : AppColors.whitecolor,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Recorded Audio',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.play_arrow),
//                           onPressed: _playAudio,
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.pause),
//                           onPressed: () {
//                             _audioPlayer.pause();
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             SizedBox(height: 50.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 30.w),
//               child: SizedBox(
//                 height: 40.h,
//                 width: MediaQuery.of(context).size.width,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle submission of the recorded file
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                   ),
//                   child: Text(
//                     'Submit file',
//                     style: TextStyle(fontSize: 18.sp, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
