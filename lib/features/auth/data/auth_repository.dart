import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  @override
  User? get currentUser {
    try {
      return _supabaseClient.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _supabaseClient.auth.onAuthStateChange.map((state) => state.session?.user);
  }

  @override
  Future<User?> signInWithEmail(final String email, final String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        throw const AuthFailure(
          'Email não confirmado. Verifique sua caixa de entrada e confirme o cadastro antes de entrar.',
        );
      }
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('invalid_credentials')) {
        throw const AuthFailure('Credenciais inválidas');
      }
      throw AuthFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<User?> signUpWithEmail(final String email, final String password) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }
}
