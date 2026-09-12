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
/// - مفيش أي طريقة لتجاوز التحديث.
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
                      UpdateDownloadFailed() => 'فشل تنزيل التحديث',
                      UpdateInstallStarted() => 'جاري فتح المثبّت...',
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
      UpdateDownloadFailed(:final message) => _FailureBody(
        message: message,
        actionLabel: 'إعادة المحاولة',
        onAction: cubit.startUpdate,
      ),
      UpdateInstallStarted() => const Padding(
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
              'يتم الآن فتح أداة تثبيت التطبيقات...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
      UpdateInstallFailed(:final message) => _FailureBody(
        message: message,
        actionLabel: 'إعادة المحاولة',
        onAction: cubit.startUpdate,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  IconData _iconFor(UpdateState state) {
    return switch (state) {
      UpdateDownloading() => Icons.download_rounded,
      UpdateDownloadFailed() => Icons.error_outline_rounded,
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

class _FailureBody extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _FailureBody({
    required this.message,
    required this.actionLabel,
    required this.onAction,
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
