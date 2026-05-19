import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: ListaiApp()));
}

class ListaiApp extends StatelessWidget {
  const ListaiApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return const MaterialApp(
      title: 'Listaí',
      home: Scaffold(
        body: Center(
          child: Text('Listaí'),
        ),
      ),
    );
  }
}
