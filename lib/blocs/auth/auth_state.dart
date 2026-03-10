import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user; // Variabel user yang dicari BLoC
  AuthAuthenticated({required this.user});
}

class AuthError extends AuthState {
  final String message; // Variabel message yang dicari BLoC
  AuthError(this.message);
}