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

/// No update is required → continue with the normal startup flow.
class UpdateNotRequired extends UpdateState {}

/// A newer optional release exists. It is not shown as a blocking gate.
class UpdateOptionalAvailable extends UpdateState {
  final ReleaseModel release;

  const UpdateOptionalAvailable(this.release);

  @override
  List<Object?> get props => [release];
}

/// Update check failed (network/server/invalid metadata) → fail open.
class UpdateCheckFailed extends UpdateState {
  final Failure failure;

  const UpdateCheckFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// A newer mandatory release exists → the update gate is shown.
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

/// The file was downloaded and is being inspected before installation.
class UpdateValidating extends UpdateState {
  final ReleaseModel release;

  const UpdateValidating(this.release);

  @override
  List<Object?> get props => [release];
}

class UpdateDownloadFailed extends UpdateState {
  final ReleaseModel release;
  final String message;

  const UpdateDownloadFailed(this.release, this.message);

  @override
  List<Object?> get props => [release, message];
}

/// The downloaded file exists but failed integrity/identity validation.
class UpdateValidationFailed extends UpdateState {
  final ReleaseModel release;
  final String message;

  const UpdateValidationFailed(this.release, this.message);

  @override
  List<Object?> get props => [release, message];
}

/// Android has not granted "install unknown apps" for this application.
class UpdateInstallPermissionRequired extends UpdateState {
  final ReleaseModel release;

  const UpdateInstallPermissionRequired(this.release);

  @override
  List<Object?> get props => [release];
}

/// The installer was opened; this does NOT mean the installation completed.
class UpdateInstallStarted extends UpdateState {
  final ReleaseModel release;
  final String apkPath;

  const UpdateInstallStarted(this.release, this.apkPath);

  @override
  List<Object?> get props => [release, apkPath];
}

class UpdateInstallFailed extends UpdateState {
  final ReleaseModel release;
  final String message;

  const UpdateInstallFailed(this.release, this.message);

  @override
  List<Object?> get props => [release, message];
}

/// The user left the gate through the bounded escape hatch after the update
/// failed repeatedly. The update is re-checked on the next app start.
class UpdateDeferred extends UpdateState {
  const UpdateDeferred();
}
