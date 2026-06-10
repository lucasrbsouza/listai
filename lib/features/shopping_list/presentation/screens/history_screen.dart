import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/shopping_list.dart';
import '../providers/current_list_provider.dart';
import '../providers/current_tab_provider.dart';
import '../providers/saved_lists_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedListsAsync = ref.watch(savedListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Compras')),
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

    // Sort by purchase date descending
    final sortedHistory = List<ShoppingList>.from(history)
      ..sort(
        (a, b) => (b.completedAt ?? b.createdAt).compareTo(
          a.completedAt ?? a.createdAt,
        ),
      );

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(savedListsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedHistory.length,
        itemBuilder: (context, index) =>
            _buildHistoryCard(context, ref, sortedHistory[index]),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    WidgetRef ref,
    ShoppingList list,
  ) {
    final purchaseDate = list.completedAt ?? list.createdAt;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(purchaseDate);
    final itemCount = list.items.length;
    final itemCountStr = itemCount == 1 ? '1 item' : '$itemCount itens';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/saved/${list.id}', extra: list),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name.isNotEmpty ? list.name : dateStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.calendar_today, dateStr),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.shopping_basket_outlined, itemCountStr),
              if (list.marketName != null && list.marketName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildInfoRow(Icons.storefront_outlined, list.marketName!),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 16)),
                  Text(
                    list.totalPrice.format(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _reuseList(context, ref, list),
                  icon: const Icon(Icons.replay),
                  label: const Text('Reutilizar lista'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[800])),
        ),
      ],
    );
  }

  void _reuseList(BuildContext context, WidgetRef ref, ShoppingList list) {
    ref
        .read(currentListProvider.notifier)
        .duplicateAndUseList(list, newName: list.name);
    ref.read(currentTabIndexProvider.notifier).state = 2;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lista "${list.name}" pronta para uma nova compra!'),
      ),
    );
    context.go('/');
  }
}
