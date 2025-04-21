import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/UserProvider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/utils/colors.dart';

class AllAudioTab extends StatefulWidget {
  const AllAudioTab({super.key});

  @override
  _AllAudioTabState createState() => _AllAudioTabState();
}

class _AllAudioTabState extends State<AllAudioTab> {
  List<DocumentSnapshot>? _audioFiles; // List to hold audio file documents
  bool _isLoading = true; // Loading state variable

  @override
  void initState() {
    super.initState();
    _fetchAudioFiles(); // Fetch audio files when the widget is initialized
  }

  Future<void> _fetchAudioFiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserData();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch audio files from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('myaudios')
          .get();

      setState(() {
        _audioFiles = snapshot.docs; // Store fetched documents
        _isLoading = false; // Stop loading
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching audio files: $e')),
      );
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  Future<void> _deleteAudioFile(String docId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserData();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    try {
      // Delete audio file from Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('myaudios')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio file deleted successfully!')),
      );

      // Refresh the audio files list
      _fetchAudioFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting audio file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? AppColors.darkblack : AppColors.homescreen,
      body: Column(
        children: [
          SizedBox(height: 20.h),
          if (_isLoading)
            Center(
                child: SpinKitFadingCircle(
              color: themeProvider.isDarkMode
                  ? AppColors.whitecolor
                  : AppColors.darkblack,
            )),
          if (!_isLoading && (_audioFiles == null || _audioFiles!.isEmpty))
            Center(
              child: Text(
                'No audio files found.',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? AppColors.whitecolor
                      : AppColors.darkblack,
                  fontSize: 18.sp,
                ),
              ),
            ),
          if (!_isLoading && _audioFiles != null)
            Expanded(
              child: ListView.builder(
                itemCount: _audioFiles!.length,
                itemBuilder: (context, index) {
                  final audioData = _audioFiles![index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Container(
                      height: 100.h,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(
                          bottom: 10.h), // Spacing between containers
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? AppColors.darkblack
                            : AppColors.homescreen,
                        borderRadius: BorderRadius.all(Radius.circular(16.r)),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10.h),
                          Text(
                            audioData['fileName'] ?? 'Unnamed Audio',
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? AppColors.whitecolor
                                  : AppColors.darkblack,
                              fontSize: 14.sp,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Delete this audio file from the record.',
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? AppColors.whitecolor
                                          : AppColors.darkblack,
                                      fontSize: 14.sp,
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
                                    _deleteAudioFile(audioData
                                        .id); // Pass document ID for deletion
                                  },
                                ),
                              ],
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
