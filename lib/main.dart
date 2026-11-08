import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr/core/config/app_config.dart';
import 'package:mr/core/di/service_locator.dart';
import 'package:mr/core/routing/app_navigator.dart';
import 'package:mr/core/routing/app_router.dart';
import 'package:mr/core/routing/routes.dart';
import 'package:mr/core/session/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fails fast on invalid APP_ENV/API_BASE_URL/STORAGE_BASE_URL instead of
  // silently talking to the wrong backend.
  AppConfig.validate();
  await setupServiceLocator();

  sl<SessionManager>().events.listen((event) {
    if (event is SessionExpired || event is SessionEnded) {
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.loginScreen,
        (route) => false,
      );
    }
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: appNavigatorKey,
        initialRoute: Routes.splash,
        onGenerateRoute: AppRouter().generateRoute,
      ),
    );
  }
}
