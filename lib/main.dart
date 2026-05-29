import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: ListaiApp()));
}

class ListaiApp extends ConsumerWidget {
  const ListaiApp({super.key});

  @override
  Widget build(final BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Listaí',
      routerConfig: goRouter,
    );
  }
}
