import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginWithGooglePressed extends AuthEvent {}
// Nanti kamu bisa tambah event lain seperti LogoutPressed, LoginWithEmailPressed, dll.
class LogoutPressed extends AuthEvent {}