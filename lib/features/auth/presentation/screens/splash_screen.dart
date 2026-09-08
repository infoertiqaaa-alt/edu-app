import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mr/core/di/service_locator.dart';
import 'package:mr/core/extensions/context_extensions.dart';
import 'package:mr/core/routing/routes.dart';
import 'package:mr/core/storage/onboarding_storage.dart';
import 'package:mr/core/theme/app_colors.dart';
import '../cubit/auto_auth_cubit.dart';
import '../cubit/auto_auth_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AutoAuthCubit>(),
      child: const _SplashBody(),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // الفحص الأول دايمًا للتوكن: لو فيه جلسة، دخّل المستخدم مباشرة
    // بدون عرض الـ onboarding نهائيًا.
    context.read<AutoAuthCubit>().checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AutoAuthCubit, AutoAuthState>(
      listener: (context, state) async {
        if (state is AutoAuthAuthenticated) {
          context.pushUntil(
            state.role == 'student' ? Routes.root : Routes.scanQrEntry,
            (route) => false,
          );
        } else if (state is AutoAuthUnauthenticated) {
          // مفيش جلسة: الـ onboarding يظهر مرة واحدة فقط في أول تشغيل،
          // وبعدها يذهب مباشرة إلى شاشة تسجيل الدخول.
          final onboardingCompleted = await sl<OnboardingStorage>()
              .isCompleted();
          if (!context.mounted) return;
          context.pushUntil(
            onboardingCompleted ? Routes.loginScreen : Routes.onBoardingView,
            (route) => false,
          );
        }
      },
      child: Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
    );
  }
}
