import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  Future<User?> signInWithEmail(final String email, final String password) async => null;

  @override
  Future<User?> signUpWithEmail(final String email, final String password) async => null;

  @override
  Future<void> signOut() async {}
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return SupabaseAuthRepository(client);
  } catch (_) {
    return FakeAuthRepository();
  }
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

class OfflineModeNotifier extends StateNotifier<bool> {
  OfflineModeNotifier() : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('is_offline_mode') ?? false;
  }

  Future<void> setOfflineMode(final bool offline) async {
    state = offline;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_offline_mode', offline);
  }
}

final isOfflineModeProvider = StateNotifierProvider<OfflineModeNotifier, bool>((ref) {
  return OfflineModeNotifier();
});
