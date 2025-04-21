import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_emotion/Provider/UserProvider.dart';
import 'package:vocal_emotion/Provider/theme_provider.dart';
import 'package:vocal_emotion/firebase_options.dart';
import 'package:vocal_emotion/view/splash_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:vocal_emotion/lib/providers/google_auth_provider.dart';
// import 'package:vocal_emotion/lib/providers/voice_record_provider.dart';
// import 'package:vocal_emotion/lib/screens/login_screen.dart';
// import 'package:vocal_emotion/lib/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  if (kIsWeb) {
    // Configure App Check for web platforms with a dummy/debug provider
    await FirebaseAppCheck.instance.activate(
      // For web, use the ReCaptchaV3Provider for development
      webProvider: ReCaptchaV3Provider('debugKeyForWeb'),
    );
  } else {
    // Keep existing configuration for mobile platforms
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // Remove providers that don't exist yet
        // ChangeNotifierProvider<GoogleAuthProvider>(
        //   create: (_) => GoogleAuthProvider(),
        // ),
        // ChangeNotifierProvider<VoiceRecordProvider>(
        //   create: (_) => VoiceRecordProvider(),
        // ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Cera Pro',
          ),
          home: const SplashScreen(),
          // Remove streambuilder with non-existent screens
          // home: StreamBuilder(
          //   stream: FirebaseAuth.instance.authStateChanges(),
          //   builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const CircularProgressIndicator();
          //     }
          //     if (snapshot.hasData) {
          //       return DashboardScreen();
          //     } else {
          //       return const LoginScreen();
          //     }
          //   },
          // ),
        );
      },
    );
  }
}
