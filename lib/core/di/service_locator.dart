import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../storage/onboarding_storage.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auto_auth_cubit.dart';
import '../../features/auth/domain/usecases/check_auth_status.dart';
import '../../features/student/data/datasources/profile_remote_data_source.dart';
import '../../features/student/data/repositories/profile_repository_impl.dart';
import '../../features/student/domain/repositories/profile_repository.dart';
import '../../features/student/presentation/cubit/profile_cubit.dart';
import '../../features/assistant/scan_qr_code/data/datasources/scan_qr_remote_data_source.dart';
import '../../features/assistant/scan_qr_code/data/repositories/scan_qr_repository_impl.dart';
import '../../features/assistant/scan_qr_code/domain/repositories/scan_qr_repository.dart';
import '../../features/assistant/scan_qr_code/presentation/cubit/scan_qr_cubit.dart';
import '../../features/lessons/data/datasources/lessons_remote_data_source.dart';
import '../../features/lessons/data/repositories/lessons_repository_impl.dart';
import '../../features/lessons/domain/repositories/lessons_repository.dart';
import '../../features/lessons/presentation/cubit/lessons_cubit.dart';
import '../../features/lessons/presentation/cubit/lesson_detail_cubit.dart';
import '../../features/lessons/presentation/cubit/lesson_notes_cubit.dart';
import '../../features/lessons/data/datasources/notes_database.dart';
import '../../features/lessons/data/repositories/lesson_notes_repository_impl.dart';
import '../../features/lessons/domain/repositories/lesson_notes_repository.dart';
import '../../features/update/data/datasources/release_remote_data_source.dart';
import '../../features/update/data/datasources/apk_installer.dart';
import '../../features/update/data/repositories/update_repository_impl.dart';
import '../../features/update/domain/repositories/update_repository.dart';
import '../../features/update/domain/usecases/get_latest_release.dart';
import '../../features/update/domain/usecases/download_latest_apk.dart';
import '../../features/update/presentation/cubit/update_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<OnboardingStorage>(() => OnboardingStorage());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>().dio),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );

  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
  sl.registerFactory<CheckAuthStatus>(
    () => CheckAuthStatus(sl<AuthRepository>()),
  );
  sl.registerFactory<AutoAuthCubit>(() => AutoAuthCubit(sl()));

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<DioClient>().dio),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl()));

  // ScanQrCode Feature Registration
  sl.registerLazySingleton<ScanQrRemoteDataSource>(
    () => ScanQrRemoteDataSourceImpl(sl<DioClient>().dio),
  );

  sl.registerLazySingleton<ScanQrRepository>(() => ScanQrRepositoryImpl(sl()));

  sl.registerFactory<ScanQrCubit>(() => ScanQrCubit(sl()));

  // Lessons Feature Registration
  sl.registerLazySingleton<LessonsRemoteDataSource>(
    () => LessonsRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<LessonsRepository>(
    () => LessonsRepositoryImpl(sl()),
  );
  sl.registerFactory<LessonsCubit>(() => LessonsCubit(sl()));
  sl.registerFactory<LessonDetailCubit>(() => LessonDetailCubit(sl()));

  // Notes Feature Registration (Local DB)
  sl.registerLazySingleton<NotesDatabase>(() => NotesDatabase.instance);
  sl.registerLazySingleton<LessonNotesRepository>(
    () => LessonNotesRepositoryImpl(sl()),
  );
  sl.registerFactory<LessonNotesCubit>(() => LessonNotesCubit(sl()));

  // Update Feature Registration
  sl.registerLazySingleton<ReleaseRemoteDataSource>(
    () => ReleaseRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<UpdateRepository>(() => UpdateRepositoryImpl(sl()));
  sl.registerLazySingleton<ApkInstaller>(() => ApkInstaller());
  sl.registerFactory<GetLatestRelease>(
    () => GetLatestRelease(sl<UpdateRepository>()),
  );
  sl.registerFactory<DownloadLatestApk>(
    () => DownloadLatestApk(sl<UpdateRepository>()),
  );
  sl.registerFactory<UpdateCubit>(
    () => UpdateCubit(
      sl<GetLatestRelease>(),
      sl<DownloadLatestApk>(),
      sl<ApkInstaller>(),
    ),
  );
}
