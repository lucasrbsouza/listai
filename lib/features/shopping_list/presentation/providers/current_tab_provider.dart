import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track and manage the active tab index in the main navigation bar.
///
/// 0: Home (Heatmap & Dashboard)
/// 1: Analíticos (Analytics Graphs)
/// 2: Lista (Active Shopping List items & Finalize)
/// 3: Criar (Create list tab action)
/// 4: Salvas (Saved & Templates list screen)
final currentTabIndexProvider = StateProvider<int>((ref) => 0);
