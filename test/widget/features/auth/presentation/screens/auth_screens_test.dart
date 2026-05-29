import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:listai/features/auth/presentation/screens/welcome_screen.dart';
import 'package:listai/features/auth/presentation/screens/login_screen.dart';
import 'package:listai/features/auth/presentation/screens/signup_screen.dart';
import 'package:listai/features/auth/presentation/providers/auth_providers.dart';
import 'package:listai/features/auth/domain/repositories/auth_repository.dart';
import 'package:listai/core/errors/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUser extends Mock implements supabase.User {}

class FakeOfflineNotifier extends OfflineModeNotifier {
  FakeOfflineNotifier(final bool initial) {
    state = initial;
  }
  @override
  Future<void> _loadState() async {}
  @override
  Future<void> setOfflineMode(final bool offline) async {
    state = offline;
  }
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late FakeOfflineNotifier fakeOfflineNotifier;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthRepository = MockAuthRepository();
    fakeOfflineNotifier = FakeOfflineNotifier(false);

    when(() => mockAuthRepository.authStateChanges()).thenAnswer((_) => Stream.value(null));
    when(() => mockAuthRepository.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest(final Widget screen) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        isOfflineModeProvider.overrideWith((ref) => fakeOfflineNotifier),
      ],
      child: MaterialApp(
        initialRoute: '/test',
        routes: {
          '/test': (context) => screen,
          '/login': (context) => const Scaffold(body: Text('Login Screen Route')),
          '/signup': (context) => const Scaffold(body: Text('Signup Screen Route')),
          '/': (context) => const Scaffold(body: Text('Home Screen Route')),
        },
      ),
    );
  }

  group('WelcomeScreen', () {
    testWidgets('renders three main buttons and branding', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const WelcomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Listaí'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Criar conta'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Continuar sem login'), findsOneWidget);
    });

    testWidgets('clicking Continuar sem login sets offline mode to true', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const WelcomeScreen()));
      await tester.pumpAndSettle();

      expect(fakeOfflineNotifier.state, isFalse);

      await tester.tap(find.widgetWithText(TextButton, 'Continuar sem login'));
      await tester.pumpAndSettle();

      expect(fakeOfflineNotifier.state, isTrue);
    });
  });

  group('LoginScreen', () {
    testWidgets('renders email, password, and submit button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid inputs', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));
      await tester.pumpAndSettle();

      // Submit empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Por favor, informe seu email', skipOffstage: false), findsOneWidget);
      expect(find.text('Senha deve ter pelo menos 8 caracteres', skipOffstage: false), findsOneWidget);

      // Enter invalid password format (no numbers)
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'passwordabc');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('A senha deve conter pelo menos uma letra e um número', skipOffstage: false), findsOneWidget);
    });

    testWidgets('submits and shows loading state on success', (tester) async {
      final mockUser = MockUser();
      when(() => mockAuthRepository.signInWithEmail('test@example.com', 'Password123'))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return mockUser;
          });

      await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'Password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump(); // Start of login

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100)); // Finish login
      await tester.pumpAndSettle();

      expect(find.text('Home Screen Route'), findsOneWidget);
    });

    testWidgets('shows general error on credential failure', (tester) async {
      when(() => mockAuthRepository.signInWithEmail('test@example.com', 'Password123'))
          .thenThrow(const AuthFailure('Credenciais inválidas'));

      await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'Password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Credenciais inválidas'), findsOneWidget);
    });
  });

  group('SignUpScreen', () {
    testWidgets('renders all fields and performs valid sign up', (tester) async {
      final mockUser = MockUser();
      when(() => mockAuthRepository.signUpWithEmail('new@example.com', 'SecurePass1'))
          .thenAnswer((_) async => mockUser);

      await tester.pumpWidget(createWidgetUnderTest(const SignUpScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'new@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'SecurePass1');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Conta'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.signUpWithEmail('new@example.com', 'SecurePass1')).called(1);
      expect(find.text('Home Screen Route'), findsOneWidget);
    });
  });
}
