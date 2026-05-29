import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/presentation/screens/current_list_screen.dart';
import 'package:listai/features/shopping_list/presentation/screens/item_form_screen.dart';
import 'package:listai/features/photo_capture/presentation/screens/photo_viewer_screen.dart';
import 'package:listai/features/settings/presentation/screens/settings_screen.dart';

import 'package:listai/features/shopping_list/presentation/screens/saved_lists_screen.dart';
import 'package:listai/features/shopping_list/presentation/screens/list_detail_screen.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';

import 'package:listai/features/auth/presentation/screens/welcome_screen.dart';
import 'package:listai/features/auth/presentation/screens/login_screen.dart';
import 'package:listai/features/auth/presentation/screens/signup_screen.dart';
import 'package:listai/features/auth/presentation/providers/auth_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isOfflineMode = ref.watch(isOfflineModeProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isAuthenticated = user != null;
      final isOffline = isOfflineMode;

      final isLoggingIn = state.matchedLocation == '/login' ||
                          state.matchedLocation == '/signup' ||
                          state.matchedLocation == '/welcome';

      if (!isAuthenticated && !isOffline) {
        if (!isLoggingIn) {
          return '/welcome';
        }
        return null;
      }

      if ((isAuthenticated || isOffline) && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const CurrentListScreen(),
      ),
      GoRoute(
        path: '/item/new',
        builder: (context, state) => const ItemFormScreen(),
      ),
      GoRoute(
        path: '/item/:id/edit',
        builder: (context, state) {
          final item = state.extra as ShoppingItem?;
          return ItemFormScreen(itemToEdit: item);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/photo-viewer',
        builder: (context, state) {
          final args = state.extra as PhotoViewerArgs;
          return PhotoViewerScreen(
            photoPath: args.photoPath,
            capturedAt: args.capturedAt,
          );
        },
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedListsScreen(),
      ),
      GoRoute(
        path: '/saved/:id',
        builder: (context, state) {
          final list = state.extra as ShoppingList;
          return ListDetailScreen(shoppingList: list);
        },
      ),
    ],
  );
});
