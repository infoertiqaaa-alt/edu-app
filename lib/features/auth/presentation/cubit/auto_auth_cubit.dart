import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_auth_status.dart';
import 'auto_auth_state.dart';

class AutoAuthCubit extends Cubit<AutoAuthState> {
  final CheckAuthStatus _checkAuthStatus;
  bool _isChecking = false;

  AutoAuthCubit(this._checkAuthStatus) : super(AutoAuthInitial());

  Future<void> checkAuthentication() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      emit(AutoAuthLoading());
      final role = await _checkAuthStatus();
      if (role == null || role.trim().isEmpty) {
        emit(AutoAuthUnauthenticated());
        return;
      }
      emit(AutoAuthAuthenticated(role.trim().toLowerCase()));
    } catch (_) {
      emit(AutoAuthUnauthenticated());
    } finally {
      _isChecking = false;
    }
  }
}
