import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/presentation/screens/current_list_screen.dart';
import 'package:listai/features/shopping_list/presentation/screens/item_form_screen.dart';
import 'package:listai/features/photo_capture/presentation/screens/photo_viewer_screen.dart';
import 'package:listai/features/settings/presentation/screens/settings_screen.dart';

import 'package:listai/features/shopping_list/presentation/screens/saved_lists_screen.dart';
import 'package:listai/features/shopping_list/presentation/screens/list_detail_screen.dart';
import 'package:listai/features/shopping_list/presentation/screens/history_screen.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';

import 'package:listai/features/analytics/presentation/screens/analytics_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/saved/:id',
        builder: (context, state) {
          final list = state.extra as ShoppingList;
          return ListDetailScreen(shoppingList: list);
        },
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});
