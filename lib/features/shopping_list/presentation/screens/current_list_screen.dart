import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/photo_capture/presentation/screens/photo_viewer_screen.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/budget_goal/presentation/providers/budget_provider.dart';
import 'package:listai/features/shopping_list/domain/usecases/check_budget_exceeded.dart';

class CurrentListScreen extends ConsumerStatefulWidget {
  const CurrentListScreen({super.key});

  @override
  ConsumerState<CurrentListScreen> createState() => _CurrentListScreenState();
}

class _CurrentListScreenState extends ConsumerState<CurrentListScreen> {
  final Set<String> _expandedSubstitutes = {};

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(currentListProvider);

    ref.listen<AsyncValue<BudgetCheckResult>>(budgetProvider, (previous, next) {
      next.when(
        data: (result) {
          if (result is ExceededBy) {
            final hasShown = ref.read(hasShownBudgetDialogProvider);
            if (!hasShown) {
              ref.read(hasShownBudgetDialogProvider.notifier).state = true;
              _showBudgetExceededDialog(context, ref, result.amount);
            }
          }
        },
        error: (_, __) {},
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Atual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/saved');
            },
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
        data: (list) {
          final substituteIds =
              list?.items
                  .map((item) => item.substituteItemId)
                  .whereType<String>()
                  .toSet() ??
              <String>{};
          final rootItems =
              list?.items
                  .where((item) => !substituteIds.contains(item.id))
                  .toList() ??
              <ShoppingItem>[];

          return Column(
            children: [
              _buildHeader(context, list?.marketName, list?.budgetGoal),
              Expanded(
                child: list == null || rootItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: rootItems.length,
                        itemBuilder: (context, index) {
                          final item = rootItems[index];
                          return _buildItemCard(
                            context,
                            ref,
                            item,
                            _findSubstitute(list.items, item),
                          );
                        },
                      ),
              ),
              if (list != null && rootItems.isNotEmpty)
                _buildFooter(context, list.totalPrice, list.exceedsBudget),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/item/new');
        },
        tooltip: 'Adicionar item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nenhuma lista atual.'),
          Text('Adicione um item para começar.'),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String? marketName,
    Money? budgetGoal,
  ) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                marketName ?? 'Sem mercado',
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showEditBudgetDialog(context, ref, budgetGoal),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(
                  budgetGoal != null
                      ? 'Meta: ${budgetGoal.format()}'
                      : 'Definir Meta',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem item,
    ShoppingItem? substitute,
  ) {
    final isSubstituteExpanded = _expandedSubstitutes.contains(item.id);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(currentListProvider.notifier).removeItem(item.id);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item removido.'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                ref.read(currentListProvider.notifier).undo();
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            ListTile(
              onTap: () => context.push('/item/${item.id}/edit', extra: item),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              title: Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productType),
                  Text(
                    '${item.quantity.value} un. × ${item.unitPrice.format()}',
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.totalPrice.format(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.photoUrl != null)
                        Tooltip(
                          message: 'Ver foto da etiqueta',
                          child: GestureDetector(
                            onTap: () {
                              context.push(
                                '/photo-viewer',
                                extra: PhotoViewerArgs(
                                  photoPath: item.photoUrl!,
                                  capturedAt: item.photoCapturedAt,
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      if (item.substituteItemId != null) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (substitute != null) ...[
              const Divider(height: 1),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (isSubstituteExpanded) {
                      _expandedSubstitutes.remove(item.id);
                    } else {
                      _expandedSubstitutes.add(item.id);
                    }
                  });
                },
                icon: const Icon(Icons.swap_horiz),
                label: Text(
                  isSubstituteExpanded
                      ? 'Ocultar substituto'
                      : 'Mostrar substituto',
                ),
              ),
              if (isSubstituteExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            substitute.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(substitute.productType),
                          Text(
                            '${substitute.quantity.value} un. × ${substitute.unitPrice.format()}',
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: () {
                                ref
                                    .read(currentListProvider.notifier)
                                    .swapWithSubstitute(item.id);
                                setState(() {
                                  _expandedSubstitutes.remove(item.id);
                                });
                              },
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('Trocar com principal'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  ShoppingItem? _findSubstitute(List<ShoppingItem> items, ShoppingItem item) {
    final substituteId = item.substituteItemId;
    if (substituteId == null) return null;

    final index = items.indexWhere((candidate) => candidate.id == substituteId);
    return index == -1 ? null : items[index];
  }

  Widget _buildFooter(BuildContext context, Money total, bool exceedsBudget) {
    final theme = Theme.of(context);
    final totalColor = exceedsBudget
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: theme.textTheme.titleLarge),
                Text(
                  total.format(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: totalColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // TODO: Finalize purchase
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Finalizar Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    Money? currentBudget,
  ) async {
    final controller = TextEditingController(
      text:
          currentBudget != null
              ? currentBudget.reais.toStringAsFixed(2).replaceAll('.', ',')
              : '',
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Definir Meta de Orçamento'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Digite o valor da meta (ex: 150,00)',
              prefixText: r'R$ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.replaceAll(',', '.');
                final value = double.tryParse(text);
                if (value != null) {
                  ref
                      .read(currentListProvider.notifier)
                      .updateBudgetGoal(Money.fromReais(value));
                } else if (text.isEmpty) {
                  ref.read(currentListProvider.notifier).updateBudgetGoal(null);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBudgetExceededDialog(
    BuildContext context,
    WidgetRef ref,
    Money exceededAmount,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Você ultrapassou o orçamento em ${exceededAmount.format()}',
          ),
          content: const Text('Deseja finalizar as compras?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuar comprando'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(currentListProvider.notifier).finalizePurchase();
              },
              child: const Text('Finalizar agora'),
            ),
          ],
        );
      },
    );
  }
}
