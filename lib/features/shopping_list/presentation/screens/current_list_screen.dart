import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/saved_lists_provider.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/photo_capture/presentation/screens/photo_viewer_screen.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/budget_goal/presentation/providers/budget_provider.dart';
import 'package:listai/features/shopping_list/domain/usecases/check_budget_exceeded.dart';
import '../../domain/entities/shopping_list.dart';
import '../../../share_export/domain/export_service.dart';
import '../../../share_export/presentation/providers/export_provider.dart';
import 'package:listai/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:listai/features/analytics/presentation/widgets/budget_heatmap.dart';
import 'package:listai/features/analytics/presentation/screens/analytics_screen.dart';
import '../providers/current_tab_provider.dart';
import 'saved_lists_screen.dart';

class CurrentListScreen extends ConsumerStatefulWidget {
  const CurrentListScreen({super.key});

  @override
  ConsumerState<CurrentListScreen> createState() => _CurrentListScreenState();
}

class _CurrentListScreenState extends ConsumerState<CurrentListScreen> {
  final Set<String> _expandedSubstitutes = {};

  Widget _buildEmptyActiveListPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma lista aberta',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use a aba "Criar" para iniciar uma nova lista ou "Salvas" para abrir uma lista existente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(currentListProvider);
    final currentIndex = ref.watch(currentTabIndexProvider);

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

    final currentList = listState.valueOrNull;
    final hasActiveList = currentList != null;

    Widget body;
    if (currentIndex == 0) {
      body = _buildNoListState(context, ref);
    } else if (currentIndex == 1) {
      body = const AnalyticsScreen();
    } else if (currentIndex == 2) {
      body = listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
        data: (list) {
          if (list == null) {
            return _buildEmptyActiveListPlaceholder(context);
          }

          final substituteIds = list.items
              .map((item) => item.substituteItemId)
              .whereType<String>()
              .toSet();
          final rootItems = list.items
              .where((item) => !substituteIds.contains(item.id))
              .toList();

          return Column(
            children: [
              _buildMarketSection(context, list.marketName),
              _buildBudgetGoal(context, list.budgetGoal),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: FilledButton.icon(
                  onPressed: () => context.push('/item/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Item'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: rootItems.isEmpty
                    ? _buildEmptyListState()
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
              if (rootItems.isNotEmpty)
                _buildFooter(context, list.totalPrice, list.exceedsBudget),
            ],
          );
        },
      );
    } else {
      body = const SavedListsScreen();
    }

    return Scaffold(
      appBar: (currentIndex == 0 || currentIndex == 2)
          ? AppBar(
              title: (currentIndex == 2 && hasActiveList)
                  ? GestureDetector(
                      onTap: () =>
                          _showRenameListDialog(context, ref, currentList.name),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              currentList.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    )
                  : Text(currentIndex == 2 ? 'Lista' : 'Listaí'),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'new_list':
                        _showCreateListDialog(context, ref);
                      case 'rename':
                        if (hasActiveList) {
                          _showRenameListDialog(context, ref, currentList.name);
                        }
                      case 'clear':
                        if (hasActiveList) {
                          _showClearAllDialog(context, ref);
                        }
                      case 'export':
                        if (hasActiveList) {
                          _showExportBottomSheet(context, ref, currentList);
                        }
                      case 'history':
                        context.push('/history');
                      case 'settings':
                        context.push('/settings');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'new_list',
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Expanded(child: Text('Nova lista')),
                        ],
                      ),
                    ),
                    if (hasActiveList) ...[
                      const PopupMenuItem<String>(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Expanded(child: Text('Renomear lista')),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Expanded(child: Text('Exportar lista')),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'clear',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep),
                            SizedBox(width: 8),
                            Expanded(child: Text('Limpar tudo')),
                          ],
                        ),
                      ),
                    ],
                    const PopupMenuItem<String>(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Expanded(child: Text('Histórico de compras')),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8),
                          Expanded(child: Text('Configurações')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : null,
      body: body,
      floatingActionButton: null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 3) {
            _showCreateListDialog(context, ref);
          } else {
            ref.read(currentTabIndexProvider.notifier).state = index;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 1 ? Icons.bar_chart : Icons.bar_chart_outlined,
            ),
            label: 'Analíticos',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 2
                  ? Icons.shopping_cart
                  : Icons.shopping_cart_outlined,
            ),
            label: 'Lista',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Criar',
            tooltip: 'Criar lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 4 ? Icons.bookmark : Icons.bookmark_border,
            ),
            label: 'Salvas',
          ),
        ],
      ),
    );
  }

  /// Screen shown when there is NO active list at all.
  Widget _buildNoListState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final heatmapAsync = ref.watch(heatmapDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Usar uma lista já existente ou criar uma nova lista',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showCreateListDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Nova Lista'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(currentTabIndexProvider.notifier).state = 4;
                  },
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Usar Lista Existente'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          heatmapAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Erro ao carregar metas: $err')),
            data: (statuses) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.grid_view_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Metas — Último Ano',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLegend(),
                  const SizedBox(height: 16),
                  if (statuses.isEmpty)
                    const Center(child: Text('Sem compras registradas ainda.'))
                  else
                    BudgetHeatmap(
                      statuses: statuses,
                      onDayTap: (status) {
                        if (!status.hasPurchase) return;
                        final spent = status.totalSpent?.format() ?? '';
                        final dateStr =
                            '${status.date.day.toString().padLeft(2, '0')}/${status.date.month.toString().padLeft(2, '0')}';
                        final text = status.budgetGoal == null
                            ? '$dateStr — Gasto: $spent'
                            : '$dateStr — Gasto: $spent de ${status.budgetGoal!.format()} (meta)';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(text),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _legendItem(const Color(0xFFE8EBE6), 'Sem compra'),
        _legendItem(const Color(0xFFc5edab), 'Sem meta'),
        _legendItem(const Color(0xFF054D28), 'Dentro da meta'),
        _legendItem(const Color(0xFFA7000D), 'Excedeu'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  /// Screen shown when a list exists but has no items yet.
  Widget _buildEmptyListState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Lista vazia.'),
          Text('Toque no + para adicionar itens.'),
        ],
      ),
    );
  }

  Widget _buildMarketSection(BuildContext context, String? marketName) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showEditMarketNameDialog(context, ref, marketName),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  marketName != null && marketName.isNotEmpty
                      ? marketName
                      : 'Definir mercado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: marketName != null && marketName.isNotEmpty
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetGoal(BuildContext context, Money? budgetGoal) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showEditBudgetDialog(context, ref, budgetGoal),
          child: Row(
            children: [
              Icon(
                Icons.flag,
                size: 18,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                budgetGoal != null
                    ? 'Meta: ${budgetGoal.format()}'
                    : 'Definir Meta',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
                    item.unitPrice != null
                        ? '${item.quantity.value} un. × ${item.unitPrice!.format()}'
                        : '${item.quantity.value} un. × preço não informado',
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.hasPrice ? item.totalPrice.format() : 'Sem preço',
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
                            substitute.unitPrice != null
                                ? '${substitute.quantity.value} un. × ${substitute.unitPrice!.format()}'
                                : '${substitute.quantity.value} un. × preço não informado',
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
                onPressed: () => _showFinalizePurchaseDialog(context, ref),
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

  Future<void> _showEditMarketNameDialog(
    BuildContext context,
    WidgetRef ref,
    String? currentMarketName,
  ) async {
    final controller = TextEditingController(text: currentMarketName ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nome do Mercado'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Ex: Supermercado Extra',
              labelText: 'Mercado',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                ref
                    .read(currentListProvider.notifier)
                    .updateMarketName(text.isEmpty ? null : text);
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    Money? currentBudget,
  ) async {
    final controller = TextEditingController(
      text: currentBudget != null
          ? currentBudget.reais.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    await showDialog<void>(
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
    await showDialog<void>(
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
                _showFinalizePurchaseDialog(context, ref);
              },
              child: const Text('Finalizar agora'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFinalizePurchaseDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final list = ref.read(currentListProvider).value;
    if (list == null || list.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione itens antes de finalizar a compra.'),
        ),
      );
      return;
    }

    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar compra?'),
          content: Text(
            'Total: ${list.totalPrice.format()}\n\n'
            'Deseja salvar esta lista como modelo antes de finalizar?',
          ),
          actionsOverflowDirection: VerticalDirection.down,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop('não_salvar'),
              child: const Text('Não Salvar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('salvar'),
              child: const Text('Salvar Lista'),
            ),
          ],
        );
      },
    );

    if (action == null) return;

    if (action == 'salvar') {
      await ref.read(currentListProvider.notifier).saveAsTemplate();
    }

    await ref.read(currentListProvider.notifier).finalizePurchase();

    if (!context.mounted) return;

    final state = ref.read(currentListProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar: ${state.error}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      ref.invalidate(savedListsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'salvar'
                ? 'Compra finalizada e lista salva como modelo!'
                : 'Compra finalizada com sucesso!',
          ),
        ),
      );
      ref.read(currentTabIndexProvider.notifier).state = 0;
    }
  }

  Future<void> _showCreateListDialog(
    BuildContext context,
    WidgetRef ref, {
    bool navigateToItemAfter = false,
  }) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nova Lista'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex: Compras da semana',
                labelText: 'Nome da lista',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite um nome para a lista';
                }
                if (value.trim().length > 100) {
                  return 'Nome muito longo (máx. 100 caracteres)';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(value.trim());
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    ref.read(currentTabIndexProvider.notifier).state = 2;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lista "$name" criada com sucesso!')),
    );

    unawaited(ref.read(currentListProvider.notifier).createNewList(name));

    if (navigateToItemAfter) {
      unawaited(context.push('/item/new'));
    }
  }

  Future<void> _showRenameListDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Renomear Lista'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome da lista',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite um nome para a lista';
                }
                if (value.trim().length > 100) {
                  return 'Nome muito longo (máx. 100 caracteres)';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(value.trim());
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (newName == null || newName.isEmpty || newName == currentName) return;

    await ref.read(currentListProvider.notifier).renameList(newName);
  }

  Future<void> _showClearAllDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsOverflowDirection: VerticalDirection.down,
          title: const Text('Limpar lista atual?'),
          content: const Text('Tem certeza? Você poderá desfazer esta ação.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(currentListProvider.notifier).saveAsTemplate();
                await ref.read(currentListProvider.notifier).clearAll();
                if (context.mounted) {
                  _showClearedSnackbar(context, ref);
                }
              },
              child: const Text('Salvar como template antes de limpar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(currentListProvider.notifier).clearAll();
                if (context.mounted) {
                  _showClearedSnackbar(context, ref);
                }
              },
              child: const Text('Limpar tudo'),
            ),
          ],
        );
      },
    );
  }

  void _showExportBottomSheet(
    BuildContext context,
    WidgetRef ref,
    ShoppingList list,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exportar lista',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Escolha o formato ideal para compartilhar sua lista:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildExportCard(
                        context,
                        icon: Icons.picture_as_pdf,
                        color: Colors.red,
                        label: 'PDF',
                        onTap: () => _performExport(
                          context,
                          ref,
                          list,
                          ExportFormat.pdf,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildExportCard(
                        context,
                        icon: Icons.text_fields,
                        color: Colors.blue,
                        label: 'TXT',
                        onTap: () => _performExport(
                          context,
                          ref,
                          list,
                          ExportFormat.txt,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildExportCard(
                        context,
                        icon: Icons.description,
                        color: Colors.indigo,
                        label: 'DOCX',
                        onTap: () => _performExport(
                          context,
                          ref,
                          list,
                          ExportFormat.docx,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildExportCard(
                        context,
                        icon: Icons.slideshow,
                        color: Colors.orange,
                        label: 'PPTX',
                        onTap: () => _performExport(
                          context,
                          ref,
                          list,
                          ExportFormat.pptx,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performExport(
    BuildContext context,
    WidgetRef ref,
    ShoppingList list,
    ExportFormat format,
  ) async {
    Navigator.of(context).pop(); // Close bottom sheet

    // Show a loading overlay or dialog
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final exportService = ref.read(exportServiceProvider);
      await exportService.exportAndShare(list, format);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lista exportada e compartilhada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearedSnackbar(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lista limpa.'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            ref.read(currentListProvider.notifier).undo();
          },
        ),
      ),
    );
  }
}
