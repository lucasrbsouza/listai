import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmail(final String email, final String password);
  Future<User?> signUpWithEmail(final String email, final String password);
  Future<void> signOut();
  Stream<User?> authStateChanges();
  User? get currentUser;
}
