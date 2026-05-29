import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/shopping_list.dart';
import '../providers/saved_lists_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedListsAsync = ref.watch(savedListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
      ),
      body: savedListsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar: $err')),
        data: (lists) {
          final history = lists.where((l) => l.isCompleted).toList();
          return _buildHistoryList(context, ref, history);
        },
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<ShoppingList> history,
  ) {
    if (history.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.refresh(savedListsProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(child: Text('Nenhuma compra finalizada ainda.')),
          ],
        ),
      );
    }

    // Sort by date descending
    final sortedHistory = List<ShoppingList>.from(history)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(savedListsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedHistory.length,
        itemBuilder: (context, index) {
          final list = sortedHistory[index];
          final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(list.createdAt);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              onTap: () => context.push('/saved/${list.id}', extra: list),
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                list.name.isNotEmpty ? list.name : dateStr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Data: $dateStr'),
                  Text('Total: ${list.totalPrice.format()}'),
                  if (list.marketName != null && list.marketName!.isNotEmpty)
                    Text('Mercado: ${list.marketName}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
