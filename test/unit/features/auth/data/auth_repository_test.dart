import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listai/core/errors/failures.dart';
import 'package:listai/features/auth/data/auth_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockSession extends Mock implements Session {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late SupabaseAuthRepository authRepository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    authRepository = SupabaseAuthRepository(mockSupabaseClient);
  });

  group('signInWithEmail', () {
    const email = 'test@example.com';
    const password = 'Password123';

    test('returns User when signInWithPassword succeeds', () async {
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();

      when(() => mockAuthResponse.user).thenReturn(mockUser);
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => mockAuthResponse);

      final result = await authRepository.signInWithEmail(email, password);

      expect(result, mockUser);
      verify(
        () => mockGoTrueClient.signInWithPassword(
          email: email,
          password: password,
        ),
      ).called(1);
    });

    test('throws AuthFailure on AuthException with generic message', () async {
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: email,
          password: password,
        ),
      ).thenThrow(
        const AuthException('Invalid login credentials', statusCode: '400'),
      );

      expect(
        () => authRepository.signInWithEmail(email, password),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.message,
            'message',
            'Credenciais inválidas',
          ),
        ),
      );
    });

    test('throws NetworkFailure on standard format exception', () async {
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: email,
          password: password,
        ),
      ).thenThrow(const FormatException('Connection failed'));

      expect(
        () => authRepository.signInWithEmail(email, password),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('signUpWithEmail', () {
    const email = 'test@example.com';
    const password = 'Password123';

    test('returns User when signUp succeeds', () async {
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();

      when(() => mockAuthResponse.user).thenReturn(mockUser);
      when(
        () => mockGoTrueClient.signUp(email: email, password: password),
      ).thenAnswer((_) async => mockAuthResponse);

      final result = await authRepository.signUpWithEmail(email, password);

      expect(result, mockUser);
      verify(
        () => mockGoTrueClient.signUp(email: email, password: password),
      ).called(1);
    });

    test('throws AuthFailure on AuthException', () async {
      when(
        () => mockGoTrueClient.signUp(email: email, password: password),
      ).thenThrow(const AuthException('Email already in use'));

      expect(
        () => authRepository.signUpWithEmail(email, password),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('signOut', () {
    test('calls auth.signOut and completes', () async {
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});

      await authRepository.signOut();

      verify(() => mockGoTrueClient.signOut()).called(1);
    });

    test('throws NetworkFailure on exception', () async {
      when(
        () => mockGoTrueClient.signOut(),
      ).thenThrow(const FormatException('Network error'));

      expect(() => authRepository.signOut(), throwsA(isA<NetworkFailure>()));
    });
  });

  group('currentUser', () {
    test('returns user when logged in', () {
      final mockUser = MockUser();
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      final result = authRepository.currentUser;

      expect(result, mockUser);
    });

    test('returns null when not logged in', () {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      final result = authRepository.currentUser;

      expect(result, isNull);
    });
  });

  group('authStateChanges', () {
    test('emits mapped users from auth state stream', () {
      final mockUser = MockUser();
      final mockSession = MockSession();
      when(() => mockSession.user).thenReturn(mockUser);

      final authState1 = AuthState(AuthChangeEvent.signedIn, mockSession);
      final authState2 = AuthState(AuthChangeEvent.signedOut, null);

      final controller = StreamController<AuthState>();
      when(
        () => mockGoTrueClient.onAuthStateChange,
      ).thenAnswer((_) => controller.stream);

      final stream = authRepository.authStateChanges();

      expectLater(stream, emitsInOrder([mockUser, null]));

      controller.add(authState1);
      controller.add(authState2);
      controller.close();
    });
  });
}
