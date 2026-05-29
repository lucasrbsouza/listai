import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/shopping_list.dart';
import '../providers/current_list_provider.dart';
import '../providers/saved_lists_provider.dart';
import '../providers/shopping_list_repository_provider.dart';
import '../providers/current_tab_provider.dart';
import '../../../../core/utils/money.dart';

class SavedListsScreen extends ConsumerWidget {
  const SavedListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedListsAsync = ref.watch(savedListsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Listas Salvas'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.list_alt),
                text: 'Minhas Listas',
              ),
              Tab(
                icon: Icon(Icons.bookmark),
                text: 'Modelos / Templates',
              ),
            ],
          ),
        ),
        body: savedListsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erro ao carregar: $err')),
          data: (lists) {
            final activeLists = lists.where((l) => !l.isTemplate && !l.isCompleted).toList();
            final templates = lists.where((l) => l.isTemplate).toList();

            return TabBarView(
              children: [
                _buildActiveListsTab(context, ref, activeLists),
                _buildTemplatesTab(context, ref, templates),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveListsTab(
    BuildContext context,
    WidgetRef ref,
    List<ShoppingList> activeLists,
  ) {
    if (activeLists.isEmpty) {
      return const Center(
        child: Text('Nenhuma lista em andamento ainda.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(savedListsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: activeLists.length,
        itemBuilder: (context, index) {
          final list = activeLists[index];
          final totalEstimated = list.items.fold<Money>(
            const Money.zero(),
            (prev, item) => prev + item.totalPrice,
          );

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          list.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteList(context, ref, list),
                        tooltip: 'Excluir lista',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${list.items.length} itens'),
                  Text('Estimativa: ${totalEstimated.format()}'),
                  if (list.marketName != null && list.marketName!.isNotEmpty)
                    Text('Mercado: ${list.marketName}'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ref.read(currentListProvider.notifier).activateList(list);
                            ref.read(currentTabIndexProvider.notifier).state = 2;
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lista "${list.name}" aberta com sucesso!')),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Abrir Lista'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(currentListProvider.notifier).duplicateAndUseList(list);
                            ref.read(currentTabIndexProvider.notifier).state = 2;
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lista duplicada com sucesso!')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Duplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplatesTab(
    BuildContext context,
    WidgetRef ref,
    List<ShoppingList> templates,
  ) {
    if (templates.isEmpty) {
      return const Center(
        child: Text('Nenhum template salvo ainda.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(savedListsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          final totalEstimated = template.items.fold<Money>(
            const Money.zero(),
            (prev, item) => prev + item.totalPrice,
          );

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteList(context, ref, template),
                        tooltip: 'Excluir template',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${template.items.length} itens'),
                  Text('Estimativa: ${totalEstimated.format()}'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(currentListProvider.notifier).duplicateAndUseList(template, newName: template.name);
                      ref.read(currentTabIndexProvider.notifier).state = 2;
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nova lista criada a partir do modelo!')),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Criar lista deste modelo'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteList(
    BuildContext context,
    WidgetRef ref,
    ShoppingList list,
  ) async {
    final title = list.isTemplate ? 'Excluir template?' : 'Excluir lista?';
    final content = list.isTemplate
        ? 'Deseja realmente excluir o template "${list.name}"?'
        : 'Deseja realmente excluir a lista "${list.name}"?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(shoppingListRepositoryProvider);
        await repository.deleteList(list.id);
        ref.invalidate(savedListsProvider);

        // If we deleted the active list, invalidate current list provider to fetch the next one
        ref.invalidate(currentListProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                list.isTemplate
                    ? 'Template excluído com sucesso!'
                    : 'Lista excluída com sucesso!',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                list.isTemplate
                    ? 'Erro ao excluir template: $e'
                    : 'Erro ao excluir lista: $e',
              ),
            ),
          );
        }
      }
    }
  }
}
