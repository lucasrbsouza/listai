import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  // Retorna uma instância global do banco.
  // Em um app real, o DB é geralmente instanciado uma vez no main.
  // Como as regras não especificam como instanciar globalmente,
  // instanciamos o banco principal e cuidamos do dispose se necessário.
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
