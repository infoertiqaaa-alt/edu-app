import 'package:flutter/material.dart';
import 'package:mr/core/routing/routes.dart';
import 'package:mr/features/auth/presentation/screens/login_screen.dart';
import 'package:mr/features/auth/presentation/screens/splash_screen.dart';
import 'package:mr/features/onboarding/views/onboard.dart';
import 'package:mr/features/root.dart';
import 'package:mr/features/student/presentation/screens/profile_view.dart';
import 'package:mr/features/assistant/scan_qr_code/presentation/views/scan_qr_entry_view.dart';
import 'package:mr/features/assistant/scan_qr_code/presentation/views/scan_qr_camera_view.dart';
import 'package:mr/features/assistant/scan_qr_code/presentation/views/scan_qr_result_view.dart';
import 'package:mr/features/lessons/presentation/screens/lesson_detail_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case Routes.onBoardingView:
        return MaterialPageRoute(builder: (context) => Onboard());
      case Routes.root:
        return MaterialPageRoute(builder: (context) => Root());
      case Routes.scanQrEntry:
        return MaterialPageRoute(builder: (context) => const ScanQrEntryView());
      case Routes.scanQrCamera:
        return MaterialPageRoute(
          builder: (context) => const ScanQrCameraView(),
        );
      case Routes.scanQrResult:
        return MaterialPageRoute(
          builder: (context) => const ScanQrResultView(),
        );
      case Routes.profileView:
        return MaterialPageRoute(builder: (context) => const ProfileView());
      case Routes.lessonDetail:
        final lessonId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => LessonDetailScreen(lessonId: lessonId),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
