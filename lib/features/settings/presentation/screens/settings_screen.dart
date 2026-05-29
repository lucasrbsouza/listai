import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listai/features/auth/presentation/providers/auth_providers.dart';
import 'package:listai/features/shopping_list/presentation/providers/shopping_list_repository_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isOffline = ref.watch(isOfflineModeProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Account / Mode Section
          if (user != null)
            _buildAuthenticatedCard(context, ref, user.email ?? 'Usuário')
          else if (isOffline)
            _buildOfflineCard(context, ref)
          else
            _buildGuestCard(context, ref),

          const SizedBox(height: 24),

          // Cloud Sync Section (Only active if user is logged in)
          if (user != null) ...[
            _buildSectionHeader('Sincronização em Nuvem'),
            const SizedBox(height: 8),
            _buildSyncControlsCard(context, ref),
            const SizedBox(height: 24),
          ],

          // App Info / Design Flourish Section
          _buildSectionHeader('Sobre o Aplicativo'),
          const SizedBox(height: 8),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(final String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAuthenticatedCard(final BuildContext context, final WidgetRef ref, final String email) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.person, size: 32, color: Colors.green[700]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conta Conectada',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.red[100]!),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Desconectar / Sair', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineCard(final BuildContext context, final WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orange[100],
                  child: Icon(Icons.cloud_off, size: 30, color: Colors.orange[700]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modo Off-line / Local',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Seus dados estão apenas no dispositivo.',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.login),
                label: const Text('Fazer Login / Criar Conta', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  // Exit offline mode so router redirects back to welcome screen
                  await ref.read(isOfflineModeProvider.notifier).setOfflineMode(false);
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCard(final BuildContext context, final WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ir para Tela de Login', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              context.go('/welcome');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSyncControlsCard(final BuildContext context, final WidgetRef ref) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.sync, color: Colors.blue[600]),
              title: const Text('Sincronização Forçada', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Forçar upload de dados pendentes locais.'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                  elevation: 0,
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronizando com o Supabase...')),
                  );
                  await ref.read(syncManagerProvider).sync();
                },
                child: const Text('Sincronizar'),
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.move_to_inbox, color: Colors.green[600]),
              title: const Text('Migrar Dados Locais', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Vincula listas off-line criadas nesta conta.'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  foregroundColor: Colors.green[700],
                  elevation: 0,
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Migrando dados offline para a nuvem...')),
                  );
                  await ref.read(syncManagerProvider).migrateLocalToCloud();
                },
                child: const Text('Migrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Versão do App', style: TextStyle(color: Colors.black54)),
                Text('1.0.0 (TDD/Offline-First)', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status da Conexão', style: TextStyle(color: Colors.black54)),
                Text('Supabase Integrado', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
