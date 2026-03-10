import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gawein/models/user_model.dart';
// Pakai import relatif agar tidak bentrok
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase;

  AuthBloc({required SupabaseClient supabase})
      : _supabase = supabase,
        super(AuthInitial()) {
    on<LoginWithGooglePressed>(_onLoginWithGooglePressed);
    on<LogoutPressed>(_onLogoutPressed);
  }

  Future<void> _onLoginWithGooglePressed(
    LoginWithGooglePressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // 1. Konfigurasi Google Sign In
      const webClientId = 'MASUKKAN_WEB_CLIENT_ID_KAMU.apps.googleusercontent.com';
      
      final googleSignIn = GoogleSignIn(serverClientId: webClientId);
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth == null) {
        emit(AuthInitial());
        return;
      }

      // 2. Autentikasi ke Supabase menggunakan token Google
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      final user = response.user;
      if (user != null) {
        // 3. LOGIKA SYNC PROFIL: Cek apakah user sudah ada di tabel profiles
        final existingProfile = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (existingProfile == null) {
          // Jika user baru, buatkan profil menggunakan data dari Google
          final newUser = UserModel(
            id: user.id,
            fullName: user.userMetadata?['full_name'] ?? 'User GaweIn',
            email: user.email ?? '',
            avatarUrl: user.userMetadata?['avatar_url'],
          );

          await _supabase.from('profiles').insert(newUser.toMap());
        }

        emit(AuthAuthenticated(user: user));
      }
    } catch (e) {
      // Pastikan constructor AuthError di auth_state.dart sesuai
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutPressed(LogoutPressed event, Emitter<AuthState> emit) async {
    await _supabase.auth.signOut();
    emit(AuthUnauthenticated());
  }
}