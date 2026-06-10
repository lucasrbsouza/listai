import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shopping_list/domain/entities/shopping_list.dart';
import '../../domain/export_format.dart';

Future<void> exportAndShareList(
  WidgetRef ref,
  ShoppingList list,
  ExportFormat format,
) {
  throw UnsupportedError('Exportação não disponível na versão web.');
}
