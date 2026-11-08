import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mr/core/theme/app_colors.dart';
import 'package:mr/core/theme/font_weight_helper.dart';

import '../../data/models/release_model.dart';
import '../cubit/update_cubit.dart';
import '../cubit/update_state.dart';

/// شاشة التحديث الإجباري.
///
/// - مفيش زر X ولا Cancel ولا Skip ولا Later.
/// - الـ back button مقفول (PopScope).
/// - الاستثناء الوحيد: لو فشل التنزيل/التحقق/التثبيت مرتين متتاليتين، يظهر زر
///   "المتابعة إلى التطبيق مؤقتًا" عشان عطل في الملف أو الشبكة ميقفلش التطبيق
///   نهائيًا على المستخدم. التحديث بيتفحص تاني في كل تشغيل.
class MandatoryUpdateView extends StatelessWidget {
  const MandatoryUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<UpdateCubit, UpdateState>(
                  builder: (context, state) {
                    final title = switch (state) {
                      UpdateDownloading() => 'جاري تنزيل التحديث...',
                      UpdateValidating() => 'جاري التحقق من التحديث...',
                      UpdateDownloadFailed() => 'فشل تنزيل التحديث',
                      UpdateValidationFailed() => 'ملف التحديث غير صالح',
                      UpdateInstallPermissionRequired() => 'مطلوب إذن التثبيت',
                      UpdateInstallStarted() => 'أكمل التثبيت',
                      UpdateInstallFailed() => 'فشل بدء التثبيت',
                      _ => 'نسخة جديدة متاحة',
                    };

                    return _Card(
                      icon: _iconFor(state),
                      title: title,
                      child: _buildBody(context, state),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UpdateState state) {
    final cubit = context.read<UpdateCubit>();

    return switch (state) {
      UpdateRequired(:final release) => _UpdateAvailableBody(
        release: release,
        onUpdateNow: cubit.startUpdate,
      ),
      UpdateDownloading(:final progress) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'برجاء الانتظار حتى يكتمل التنزيل.\nلا يمكنك استخدام التطبيق قبل التحديث.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1E4DF),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeightHelper.bold,
            ),
          ),
        ],
      ),
      UpdateValidating() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'يتم التحقق من سلامة الملف وتوقيعه قبل التثبيت...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
      UpdateDownloadFailed(:final message) => _FailureBody(
        message: message,
        actionLabel: 'إعادة المحاولة',
        onAction: cubit.startUpdate,
        onContinue: cubit.canContinueOffline
            ? cubit.continueWithoutUpdate
            : null,
      ),
      UpdateValidationFailed(:final message) => _FailureBody(
        message: message,
        actionLabel: 'إعادة المحاولة',
        onAction: cubit.startUpdate,
        onContinue: cubit.canContinueOffline
            ? cubit.continueWithoutUpdate
            : null,
      ),
      UpdateInstallPermissionRequired() => _PermissionBody(
        onOpenSettings: cubit.openInstallPermissionSettings,
        onRetry: cubit.startUpdate,
      ),
      UpdateInstallStarted() => _FailureBody(
        message:
            'تم فتح أداة تثبيت التطبيقات. أكمل التثبيت من الشاشة التي ظهرت. '
            'إذا ألغيت التثبيت أو لم تكتمل العملية، اضغط إعادة المحاولة.',
        actionLabel: 'إعادة فتح المثبّت',
        onAction: cubit.startUpdate,
        onContinue: cubit.canContinueOffline
            ? cubit.continueWithoutUpdate
            : null,
      ),
      UpdateInstallFailed(:final message) => _FailureBody(
        message: message,
        actionLabel: 'إعادة المحاولة',
        onAction: cubit.startUpdate,
        onContinue: cubit.canContinueOffline
            ? cubit.continueWithoutUpdate
            : null,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  IconData _iconFor(UpdateState state) {
    return switch (state) {
      UpdateDownloading() => Icons.download_rounded,
      UpdateValidating() => Icons.verified_user_rounded,
      UpdateDownloadFailed() => Icons.error_outline_rounded,
      UpdateValidationFailed() => Icons.gpp_bad_rounded,
      UpdateInstallPermissionRequired() => Icons.settings_applications_rounded,
      UpdateInstallStarted() => Icons.system_update_alt_rounded,
      UpdateInstallFailed() => Icons.error_outline_rounded,
      _ => Icons.new_releases_rounded,
    };
  }
}

class _UpdateAvailableBody extends StatelessWidget {
  final ReleaseModel release;
  final VoidCallback onUpdateNow;

  const _UpdateAvailableBody({
    required this.release,
    required this.onUpdateNow,
  });

  @override
  Widget build(BuildContext context) {
    final versionName = release.versionName;
    final changelog = release.changelog;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'التحديث مطلوب للمتابعة',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'الإصدار: $versionName',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeightHelper.extraBold,
          ),
        ),
        if (changelog.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF3EF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1E4DF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'التغييرات:',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeightHelper.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  changelog,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onUpdateNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'تحديث الآن',
              style: TextStyle(fontSize: 17, fontWeight: FontWeightHelper.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _PermissionBody extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  const _PermissionBody({required this.onOpenSettings, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'يحتاج التطبيق إلى إذن "تثبيت التطبيقات غير المعروفة" لإكمال التحديث. '
          'افتح الإعدادات وامنح الإذن ثم اضغط إعادة المحاولة.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onOpenSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'فتح إعدادات التثبيت',
              style: TextStyle(fontSize: 17, fontWeight: FontWeightHelper.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onRetry,
          child: const Text(
            'إعادة المحاولة',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeightHelper.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _FailureBody extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  /// Shown only after the same update failed repeatedly, so a broken or
  /// unreachable artifact cannot lock users out of the app forever.
  final VoidCallback? onContinue;

  const _FailureBody({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeightHelper.bold,
              ),
            ),
          ),
        ),
        if (onContinue != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onContinue,
            child: const Text(
              'المتابعة إلى التطبيق مؤقتًا',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeightHelper.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _Card({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECE9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeightHelper.bold,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
