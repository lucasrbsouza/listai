import 'package:flutter/material.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:intl/intl.dart';

class ListDetailScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ListDetailScreen({super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(shoppingList.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shoppingList.name.isNotEmpty
              ? shoppingList.name
              : 'Detalhes da Lista',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, dateStr),
          Expanded(
            child: shoppingList.items.isEmpty
                ? const Center(child: Text('Esta lista não possui itens.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: shoppingList.items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = shoppingList.items[index];
                      return ListTile(
                        title: Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.isWeightBased
                              ? '\${item.quantity.format()} kg x \${item.unitPrice.format()} /kg'
                              : '\${item.quantity.format()} un x \${item.unitPrice.format()}',
                        ),
                        trailing: Text(
                          item.totalPrice.format(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String dateStr) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shoppingList.isTemplate)
            const Chip(label: Text('Template'))
          else ...[
            Text(
              'Data: \$dateStr',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (shoppingList.marketName != null &&
                shoppingList.marketName!.isNotEmpty)
              Text('Mercado: \${shoppingList.marketName}'),
            if (shoppingList.budgetGoal != null)
              Text('Meta de gastos: \${shoppingList.budgetGoal!.format()}'),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final total = shoppingList.totalPrice;
    final exceeded = shoppingList.exceedsBudget;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              total.format(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: exceeded ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
