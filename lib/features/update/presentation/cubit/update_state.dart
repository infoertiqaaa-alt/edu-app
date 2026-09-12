import 'package:equatable/equatable.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../../data/models/release_model.dart';

abstract class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object?> get props => [];
}

class UpdateInitial extends UpdateState {}

class UpdateChecking extends UpdateState {}

/// لا يوجد تحديث مطلوب → المتابعة للتدفق الطبيعي.
class UpdateNotRequired extends UpdateState {}

/// فشل فحص التحديث (شبكة/خادم) → نكمل طبيعي بدون حجب، بحسب سياسة الأخطاء.
class UpdateCheckFailed extends UpdateState {
  final Failure failure;

  const UpdateCheckFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// يوجد إصدار أحدث → التحديث إجباري ولا يمكن تجاوزه.
class UpdateRequired extends UpdateState {
  final ReleaseModel release;

  const UpdateRequired(this.release);

  @override
  List<Object?> get props => [release];
}

class UpdateDownloading extends UpdateState {
  final ReleaseModel release;
  final int receivedBytes;
  final int totalBytes;

  const UpdateDownloading(
    this.release, {
    this.receivedBytes = 0,
    this.totalBytes = 0,
  });

  double get progress {
    if (totalBytes <= 0) return 0;
    final value = receivedBytes / totalBytes;
    return value.clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [release, receivedBytes, totalBytes];
}

class UpdateDownloadFailed extends UpdateState {
  final ReleaseModel release;
  final String message;

  const UpdateDownloadFailed(this.release, this.message);

  @override
  List<Object?> get props => [release, message];
}

/// تم تنزيل الـ APK وبدأناه في فتح المثبّت (مش معناه إن التثبيت اكتمل).
class UpdateInstallStarted extends UpdateState {
  final ReleaseModel release;
  final String apkPath;

  const UpdateInstallStarted(this.release, this.apkPath);

  @override
  List<Object?> get props => [release, apkPath];
}

/// فشل بدء المثبّت (مثلاً: لا يوجد app للتثبيت أو المشغل اتعطل).
class UpdateInstallFailed extends UpdateState {
  final ReleaseModel release;
  final String message;

  const UpdateInstallFailed(this.release, this.message);

  @override
  List<Object?> get props => [release, message];
}
