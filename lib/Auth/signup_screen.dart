import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocal_emotion/Auth/login_screen.dart';
import 'package:vocal_emotion/utils/colors.dart';
import 'package:vocal_emotion/utils/animations.dart';
import 'package:vocal_emotion/widgets/image_source_selector.dart';
import 'package:vocal_emotion/widgets/futuristic_components.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  bool _obscurePassword = true;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (BuildContext context) {
        return ImageSourceSelector(
          onImageSelected: (source) {
            _pickImage(source);
          },
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _signup() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields and select an image."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String imageUrl = await uploadImageToFirebase(userCredential.user!.uid);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Account created successfully, ${_usernameController.text.trim()}!",
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup failed: ${e.toString()}"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> uploadImageToFirebase(String userId) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('users/$userId/profile.jpg');

    await storageRef.putFile(_image!);

    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          CustomPaint(
            painter: ParticlePainter(
              controller: _animationController,
              particleColor: AppColors.tertiary.withOpacity(0.4),
              particleCount: 40,
            ),
            child: const SizedBox.expand(),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Back button
                    SlideInAnimation(
                      beginOffset: const Offset(-30, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary,
                            size: 20.w,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Header text
                    Center(
                      child: FadeInAnimation(
                        child: Column(
                          children: [
                            GlitchText(
                              text: 'CREATE ACCOUNT',
                              style: TextStyle(
                                fontSize: 28.sp,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontFamily: 'Kodchasan',
                              ),
                              isActive: false,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Sign up to explore and analyze your emotions through speech',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Profile picture selection
                    Center(
                      child: SlideInAnimation(
                        beginOffset: const Offset(0, 30),
                        delay: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: _showImageSourceSelector,
                          child: Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _image == null
                                    ? AppColors.blueGradient
                                    : AppColors.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.surfaceLight.withOpacity(0.5),
                                width: 4,
                              ),
                            ),
                            child: _image != null
                                ? ClipOval(
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.add_a_photo,
                                    color: AppColors.textPrimary,
                                    size: 40.w,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Username field
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 300),
                      beginOffset: const Offset(0, 30),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FuturisticTextField(
                          controller: _usernameController,
                          labelText: 'Username',
                          focusNode: _usernameFocusNode,
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Email field
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 400),
                      beginOffset: const Offset(0, 30),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FuturisticTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          focusNode: _emailFocusNode,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Password field
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 500),
                      beginOffset: const Offset(0, 30),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FuturisticTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          focusNode: _passwordFocusNode,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          isPassword: true,
                          onSuffixIconPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Signup button
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 600),
                      beginOffset: const Offset(0, 30),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? ShimmerLoading(
                                baseColor: AppColors.secondary.withOpacity(0.2),
                                highlightColor:
                                    AppColors.secondary.withOpacity(0.6),
                                child: NeonButton(
                                  text: 'CREATING ACCOUNT...',
                                  glowColor: AppColors.secondary,
                                  width: MediaQuery.of(context).size.width,
                                  onPressed: () {},
                                  isPulsing: false,
                                ),
                              )
                            : NeonButton(
                                text: 'CREATE ACCOUNT',
                                glowColor: AppColors.secondary,
                                width: MediaQuery.of(context).size.width,
                                onPressed: _signup,
                              ),
                      ),
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String asset, Color color) {
    return GestureDetector(
      onTap: () {
        // Social signup functionality
      },
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: SvgPicture.asset(
            asset,
            colorFilter: ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
