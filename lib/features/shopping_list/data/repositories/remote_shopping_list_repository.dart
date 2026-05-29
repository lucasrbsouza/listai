import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listai/core/errors/failures.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';

class RemoteShoppingListRepository implements ShoppingListRepository {
  RemoteShoppingListRepository(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  ShoppingList _mapList(final Map<String, dynamic> listMap, final List<Map<String, dynamic>> itemsMaps) {
    return ShoppingList(
      id: listMap['id'] as String,
      userId: listMap['user_id'] as String?,
      name: listMap['name'] as String,
      marketName: listMap['market_name'] as String?,
      budgetGoal: listMap['budget_goal_cents'] != null
          ? Money.fromCents(listMap['budget_goal_cents'] as int)
          : null,
      isCompleted: listMap['is_completed'] as bool? ?? false,
      isTemplate: listMap['is_template'] as bool? ?? false,
      completedAt: listMap['completed_at'] != null
          ? DateTime.parse(listMap['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(listMap['created_at'] as String),
      updatedAt: DateTime.parse(listMap['updated_at'] as String),
      items: itemsMaps.map(_mapItem).toList(),
    );
  }

  ShoppingItem _mapItem(final Map<String, dynamic> itemMap) {
    return ShoppingItem(
      id: itemMap['id'] as String,
      productType: itemMap['product_type'] as String,
      productName: itemMap['product_name'] as String,
      brand: itemMap['brand'] as String?,
      quantity: Quantity((itemMap['quantity_value'] as num).toDouble()),
      unitPrice: Money.fromCents(itemMap['unit_price_cents'] as int),
      isWholesale: itemMap['is_wholesale'] as bool? ?? false,
      isWeightBased: itemMap['is_weight_based'] as bool? ?? false,
      pricePerKg: itemMap['price_per_kg_cents'] != null
          ? Money.fromCents(itemMap['price_per_kg_cents'] as int)
          : null,
      weightKg: itemMap['weight_kg'] != null
          ? Quantity((itemMap['weight_kg'] as num).toDouble())
          : null,
      photoUrl: itemMap['photo_url'] as String?,
      photoCapturedAt: itemMap['photo_captured_at'] != null
          ? DateTime.parse(itemMap['photo_captured_at'] as String)
          : null,
      substituteItemId: itemMap['substitute_item_id'] as String?,
      position: itemMap['position'] as int,
      createdAt: DateTime.parse(itemMap['created_at'] as String),
    );
  }

  Map<String, dynamic> _listToJson(final ShoppingList list) {
    return {
      'id': list.id,
      'user_id': list.userId,
      'name': list.name,
      'market_name': list.marketName,
      'budget_goal_cents': list.budgetGoal?.cents,
      'is_completed': list.isCompleted,
      'is_template': list.isTemplate,
      'completed_at': list.completedAt?.toIso8601String(),
      'created_at': list.createdAt.toIso8601String(),
      'updated_at': list.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _itemToJson(final ShoppingItem item, final String listId) {
    return {
      'id': item.id,
      'list_id': listId,
      'product_type': item.productType,
      'product_name': item.productName,
      'brand': item.brand,
      'quantity_value': item.quantity.value,
      'unit_price_cents': item.unitPrice.cents,
      'is_wholesale': item.isWholesale,
      'is_weight_based': item.isWeightBased,
      'price_per_kg_cents': item.pricePerKg?.cents,
      'weight_kg': item.weightKg?.value,
      'photo_url': item.photoUrl,
      'photo_captured_at': item.photoCapturedAt?.toIso8601String(),
      'substitute_item_id': item.substituteItemId,
      'position': item.position,
      'created_at': item.createdAt.toIso8601String(),
    };
  }

  @override
  Future<ShoppingList?> getCurrentList() async {
    try {
      final listRows = await _supabaseClient
          .from('shopping_lists')
          .select()
          .eq('is_completed', false)
          .eq('is_template', false)
          .order('updated_at', ascending: false)
          .limit(1);

      if (listRows.isEmpty) return null;
      final listMap = listRows.first;

      final itemRows = await _supabaseClient
          .from('shopping_items')
          .select()
          .eq('list_id', listMap['id'] as String)
          .order('position', ascending: true);

      return _mapList(listMap, List<Map<String, dynamic>>.from(itemRows));
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> saveCurrentList(final ShoppingList list) async {
    try {
      await _supabaseClient.from('shopping_lists').upsert(_listToJson(list));

      await _supabaseClient
          .from('shopping_items')
          .delete()
          .eq('list_id', list.id);

      if (list.items.isNotEmpty) {
        final itemsJson = list.items.map((i) => _itemToJson(i, list.id)).toList();
        await _supabaseClient.from('shopping_items').insert(itemsJson);
      }
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<ShoppingList>> getSavedLists() async {
    try {
      final listRows = await _supabaseClient
          .from('shopping_lists')
          .select()
          .or('is_completed.eq.true,is_template.eq.true')
          .order('updated_at', ascending: false);

      final List<ShoppingList> lists = [];
      for (final listMap in listRows) {
        final itemRows = await _supabaseClient
            .from('shopping_items')
            .select()
            .eq('list_id', listMap['id'] as String)
            .order('position', ascending: true);
        lists.add(_mapList(listMap, List<Map<String, dynamic>>.from(itemRows)));
      }
      return lists;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<ShoppingList> getListById(final String id) async {
    try {
      final listRows = await _supabaseClient
          .from('shopping_lists')
          .select()
          .eq('id', id);

      if (listRows.isEmpty) throw NotFoundFailure('List not found: $id');
      final listMap = listRows.first;

      final itemRows = await _supabaseClient
          .from('shopping_items')
          .select()
          .eq('list_id', id)
          .order('position', ascending: true);

      return _mapList(listMap, List<Map<String, dynamic>>.from(itemRows));
    } on Failure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> saveAsTemplate(final ShoppingList list) async {
    final template = list.copyWith(isTemplate: true);
    await saveCurrentList(template);
  }

  @override
  Future<void> deleteList(final String id) async {
    try {
      final rows = await _supabaseClient
          .from('shopping_lists')
          .delete()
          .eq('id', id)
          .select();

      if (rows.isEmpty) throw NotFoundFailure('List not found: $id');
    } on Failure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> finalizePurchase(final ShoppingList list) async {
    try {
      await _supabaseClient.rpc(
        'finalize_purchase',
        params: {'p_list_id': list.id},
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Stream<ShoppingList?> watchCurrentList() {
    final controller = StreamController<ShoppingList?>();

    getCurrentList().then((list) {
      if (!controller.isClosed) {
        controller.add(list);
      }
    }).catchError((_) {});

    final channel = _supabaseClient.channel('current_list_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shopping_lists',
          callback: (payload) async {
            final list = await getCurrentList();
            if (!controller.isClosed) {
              controller.add(list);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shopping_items',
          callback: (payload) async {
            final list = await getCurrentList();
            if (!controller.isClosed) {
              controller.add(list);
            }
          },
        );

    channel.subscribe();

    controller.onCancel = () {
      _supabaseClient.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }
}
