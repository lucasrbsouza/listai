import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/core/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mcfpcyxrnqqrpjxuqkbn.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jZnBjeXhybnFxcnBqeHVxa2JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNjMyOTUsImV4cCI6MjA5NTYzOTI5NX0.ZSg0Mf3zafjiASRVjbV8mx993--Iot2xZroG8pRKMD0',
  );

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  runApp(const ProviderScope(child: ListaiApp()));
}

class ListaiApp extends ConsumerWidget {
  const ListaiApp({super.key});

  @override
  Widget build(final BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(title: 'Listaí', routerConfig: goRouter);
  }
}
