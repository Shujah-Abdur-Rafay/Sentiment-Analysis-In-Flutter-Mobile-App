import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/UserProvider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ChooseAudioScreen extends StatefulWidget {
  const ChooseAudioScreen({super.key});

  @override
  _ChooseAudioScreenState createState() => _ChooseAudioScreenState();
}

class _ChooseAudioScreenState extends State<ChooseAudioScreen> {
  String? _audioFileName; // Variable to hold the selected audio file name
  File? _audioFile; // Variable to hold the selected audio file for mobile
  Uint8List? _audioBytes; // Variable to hold the selected audio bytes for web
  bool _isLoading = false; // Loading state variable

  Future<void> _pickAudioFile() async {
    // Open the file picker for audio files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      // If the user selected a file, update the state with the file name and file
      setState(() {
        _audioFileName = result.files.first.name; // Get the file name
        
        if (kIsWeb) {
          // For web, use bytes
          _audioBytes = result.files.first.bytes;
        } else {
          // For mobile, use path
          _audioFile = File(result.files.first.path!);
        }
      });
    }
  }

  Future<void> _uploadAudioFile() async {
    if (_audioFile == null && _audioBytes == null) {
      // Ensure a file is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an audio file first.')),
      );
      return;
    }

    // Get the current user from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserData();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true
    });

    // Upload the audio file to Firebase Storage
    try {
      String filePath = 'myaudios/${currentUser.uid}/$_audioFileName';
      
      if (kIsWeb) {
        // For web, use putData with bytes
        await FirebaseStorage.instance.ref(filePath).putData(_audioBytes!);
      } else {
        // For mobile, use putFile
        await FirebaseStorage.instance.ref(filePath).putFile(_audioFile!);
      }

      // Create a reference to the Firestore collection
      final audioRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('myaudios');

      // Add audio file info to the Firestore collection
      await audioRef.add({
        'fileName': _audioFileName,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio file uploaded successfully!')),
      );

      // Clear the selected audio file
      setState(() {
        _audioFileName = null;
        _audioFile = null;
        _audioBytes = null;
      });

      // Navigate back after upload
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading audio: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? AppColors.darkblack : AppColors.homescreen,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode
            ? AppColors.whitecolor
            : AppColors.darkblack,
        title: Text(
          'Choose Audio File',
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? AppColors.darkblack
                : AppColors.whitecolor,
            fontSize: 19.sp,
          ),
        ),
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode
              ? AppColors.darkblack
              : AppColors.whitecolor,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            Text(
              'Please Select Audio File from your phone so we can tell you about your emotions',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? AppColors.whitecolor
                    : AppColors.textfieldheading,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 50.h),
            GestureDetector(
              onTap: _pickAudioFile,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? AppColors.darkblack
                      : AppColors.whitecolor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _audioFileName ??
                          'Choose an audio file from your phone (small size recommended)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.isDarkMode
                            ? AppColors.whitecolor
                            : AppColors.textfieldheading,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_audioFileName != null)
                      Text(
                        'Selected: $_audioFileName',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: SizedBox(
                height: 40.h,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _uploadAudioFile, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.isDarkMode
                        ? AppColors.whitecolor
                        : AppColors.darkblack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: themeProvider.isDarkMode
                                ? AppColors.darkblack
                                : AppColors.whitecolor,
                          ),
                        )
                      : Text(
                          'Submit file',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: themeProvider.isDarkMode
                                ? AppColors.darkblack
                                : AppColors.whitecolor,
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
