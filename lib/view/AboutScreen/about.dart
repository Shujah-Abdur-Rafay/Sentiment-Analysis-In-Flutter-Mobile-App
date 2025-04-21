import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/UserProvider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/utils/icons.dart';
import 'package:vocal_emotion/widgets/CustomElevatedButton.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool isDarkModeEnabled = false;
  bool isBiometricLoginEnabled = false;
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    // Fetch user data when the screen initializes
    Provider.of<UserProvider>(context, listen: false).fetchUserData();
  }

  bool _isImageLoading = true;
  void _showDeleteAccountBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 250.h,
          decoration: BoxDecoration(
            color: AppColors.whitecolor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete Account',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone.',
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomElevatedButton(
                      text: 'Yes',
                      onPressed: () {},
                    ),
                    SizedBox(width: 20.w),
                    CustomElevatedButton(
                      text: 'No',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? AppColors.darkblack : AppColors.whitecolor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? AppColors.whitecolor
                              : AppColors.darkblack,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            const Divider(color: AppColors.movingcolor),
            SizedBox(height: 30.h),

            // Centering the CircleAvatar and Username
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70.r,
                    backgroundColor: themeProvider.isDarkMode
                        ? Colors.red
                        : AppColors.buttoncolor,
                    child: currentUser?.imageUrl.isNotEmpty == true
                        ? ClipOval(
                            child: Image.network(
                              currentUser!.imageUrl,
                              fit: BoxFit.cover,
                              width: 125.r,
                              height: 125.r,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  _isImageLoading =
                                      false; // Set loading to false
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person,
                                    size: 30.r); // Show default icon on error
                              },
                            ),
                          )
                        : Icon(Icons.person,
                            size: 30.r), // Default icon if no image
                  ),
                  SizedBox(height: 10.h), // Space between avatar and name
                  Text(
                    currentUser?.username ?? 'Guest',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? AppColors.whitecolor
                          : AppColors.secondarycolor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    currentUser?.email ?? 'Dummy',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? AppColors.whitecolor
                          : AppColors.secondarycolor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                children: [
                  _buildSettingsRow(
                      AppIcons.bell, 'Notification Settings', themeProvider),
                  SizedBox(height: 10.h),
                  _buildToggleRow(
                    AppIcons.dark,
                    'Dark mode',
                    themeProvider.isDarkMode,
                    (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildToggleRow(
                    AppIcons.faceid,
                    'Biometric login',
                    isBiometricLoginEnabled,
                    (value) {
                      setState(() {
                        isBiometricLoginEnabled = value;
                      });
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildSettingsRow(
                    AppIcons.language,
                    'Change language',
                    themeProvider,
                    onTap: () => _showLanguageBottomSheet(context),
                  ),
                  SizedBox(height: 20.h),
                  _buildSettingsRow(
                    AppIcons.userremove,
                    'Delete account',
                    themeProvider,
                    onTap: () => _showDeleteAccountBottomSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
      String iconPath, String title, ThemeProvider themeProvider,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            height: 22.h,
            width: 20.h,
            color: themeProvider.isDarkMode
                ? AppColors.whitecolor
                : AppColors.darkblack,
          ),
          SizedBox(width: 20.w),
          Text(
            title,
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? AppColors.whitecolor
                  : AppColors.darkblack,
              fontSize: 16.sp,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: themeProvider.isDarkMode
                ? AppColors.whitecolor
                : AppColors.darkblack,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
      String iconPath, String title, bool value, Function(bool) onChanged) {
    final themeProvider = Provider.of<ThemeProvider>(context,
        listen: false); // Access the theme provider

    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          height: 22.h,
          width: 20.h,
          color: themeProvider.isDarkMode
              ? AppColors.whitecolor
              : AppColors.darkblack,
        ),
        SizedBox(width: 20.w),
        Text(
          title,
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? AppColors.whitecolor
                : AppColors.darkblack,
            fontSize: 16.sp,
          ),
        ),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.buttoncolor,
        ),
      ],
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: AppColors.whitecolor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildLanguageOption('English', AppIcons.english),
                _buildLanguageOption('Urdu', AppIcons.urdu),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, String assetPath) {
    return ListTile(
      leading: SvgPicture.asset(
        assetPath,
        height: 32.h,
        width: 32.h,
      ),
      title: Text(language),
      trailing: Radio<String>(
        value: language,
        groupValue: selectedLanguage,
        onChanged: (value) {
          setState(() {
            selectedLanguage = value!;
          });
          Navigator.pop(context);
        },
        activeColor: Colors.green,
      ),
    );
  }
}
