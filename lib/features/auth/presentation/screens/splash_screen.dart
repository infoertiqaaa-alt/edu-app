import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mr/core/di/service_locator.dart';
import 'package:mr/core/extensions/context_extensions.dart';
import 'package:mr/core/routing/routes.dart';
import 'package:mr/core/storage/onboarding_storage.dart';
import 'package:mr/core/theme/app_colors.dart';
import 'package:mr/features/update/presentation/cubit/update_cubit.dart';
import 'package:mr/features/update/presentation/cubit/update_state.dart';
import 'package:mr/features/update/presentation/widgets/mandatory_update_view.dart';
import '../cubit/auto_auth_cubit.dart';
import '../cubit/auto_auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AutoAuthCubit>()..checkAuthentication()),
        BlocProvider(create: (_) => sl<UpdateCubit>()..checkForUpdate()),
      ],
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
  String? _targetRoute;
  bool _authResolved = false;
  bool _proceedToNavigation = false;

  /// بنتنقل بس لما الاتنين يبقوا جاهزين:
  /// الفحص الرسمي انتهى (تحديث مش مطلوب أو الفحص فشل) والـ auth حدد وجهته.
  void _tryNavigate() {
    if (!_authResolved || !_proceedToNavigation) return;
    if (_targetRoute == null) return;
    context.pushUntil(_targetRoute!, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCubit, UpdateState>(
      listener: (context, state) {
        // اتباع سياسة الأخطاء: الفشل في فحص التحديث لا يمنع التطبيق.
        if (state is UpdateNotRequired || state is UpdateCheckFailed) {
          _proceedToNavigation = true;
          _tryNavigate();
        }
        // بعد بدء المثبّت نكمل التدفق الطبيعي؛ التحديث نفسه يُختبر مجددًا
        // في الإقلاع التالي في حالة ألغى المستخدم التثبيت.
        if (state is UpdateInstallStarted) {
          _proceedToNavigation = true;
          _tryNavigate();
        }
      },
      child: BlocListener<AutoAuthCubit, AutoAuthState>(
        listener: (context, state) async {
          if (state is AutoAuthAuthenticated) {
            _targetRoute = state.role == 'student'
                ? Routes.root
                : Routes.scanQrEntry;
            _authResolved = true;
            _tryNavigate();
          } else if (state is AutoAuthUnauthenticated) {
            final onboardingCompleted = await sl<OnboardingStorage>()
                .isCompleted();
            if (!context.mounted) return;
            _targetRoute = onboardingCompleted
                ? Routes.loginScreen
                : Routes.onBoardingView;
            _authResolved = true;
            _tryNavigate();
          }
        },
        child: BlocBuilder<UpdateCubit, UpdateState>(
          builder: (context, state) {
            if (_isBlockingUpdateState(state)) {
              return const MandatoryUpdateView();
            }
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isBlockingUpdateState(UpdateState state) {
    return state is UpdateRequired ||
        state is UpdateDownloading ||
        state is UpdateDownloadFailed ||
        state is UpdateInstallStarted ||
        state is UpdateInstallFailed;
  }
}
