import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listai/core/errors/failures.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/data/repositories/remote_shopping_list_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock 
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  
  @override
  MockPostgrestFilterBuilder eq(final String column, final Object value) => this;

  @override
  MockPostgrestFilterBuilder order(final String column, {final bool ascending = true, final bool nullsFirst = false, final bool foreignTable = false}) => this;

  @override
  MockPostgrestFilterBuilder limit(final int count, {final String? referencedTable}) => this;

  @override
  MockPostgrestFilterBuilder select([final String? columns]) => this;

  @override
  MockPostgrestFilterBuilder or(final String filters, {final String? referencedTable}) => this;

  List<dynamic> mockDataQueue = [];
  Object? forceError;

  @override
  Future<T> then<T>(final FutureOr<T> Function(List<Map<String, dynamic>>) onValue, {final Function? onError}) {
    if (forceError != null) {
      return Future<List<Map<String, dynamic>>>.error(forceError!).then(onValue, onError: onError);
    }
    final data = mockDataQueue.isNotEmpty ? mockDataQueue.removeAt(0) : <Map<String, dynamic>>[];
    return Future.value(data as List<Map<String, dynamic>>).then(onValue, onError: onError);
  }
}

class MockRpcFilterBuilder extends Mock 
    implements PostgrestFilterBuilder<dynamic> {
  
  List<dynamic> mockDataQueue = [];
  Object? forceError;

  @override
  Future<T> then<T>(final FutureOr<T> Function(dynamic) onValue, {final Function? onError}) {
    if (forceError != null) {
      return Future<dynamic>.error(forceError!).then(onValue, onError: onError);
    }
    final data = mockDataQueue.isNotEmpty ? mockDataQueue.removeAt(0) : null;
    return Future.value(data).then(onValue, onError: onError);
  }
}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockRpcFilterBuilder mockRpcBuilder;
  late RemoteShoppingListRepository remoteRepository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockRpcBuilder = MockRpcFilterBuilder();

    when(() => mockSupabaseClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockQueryBuilder.upsert(any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockQueryBuilder.delete()).thenAnswer((_) => mockFilterBuilder);

    remoteRepository = RemoteShoppingListRepository(mockSupabaseClient);
  });

  ShoppingList createTestList() {
    return ShoppingList(
      id: 'list-1',
      userId: 'user-1',
      name: 'Lista de Teste',
      marketName: 'Mercado Teste',
      budgetGoal: Money.fromCents(15000),
      createdAt: DateTime.parse('2026-05-29T10:00:00Z'),
      updatedAt: DateTime.parse('2026-05-29T10:00:00Z'),
      items: [
        ShoppingItem(
          id: 'item-1',
          productType: 'Alimento',
          productName: 'Arroz',
          brand: 'Prato Fino',
          quantity: Quantity(2),
          unitPrice: Money.fromCents(2500),
          position: 0,
          createdAt: DateTime.parse('2026-05-29T10:00:00Z'),
        )
      ],
    );
  }

  group('getCurrentList', () {
    test('returns ShoppingList when a list exists', () async {
      final list = createTestList();
      final listData = [
        {
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
        }
      ];

      final itemData = [
        {
          'id': list.items.first.id,
          'product_type': list.items.first.productType,
          'product_name': list.items.first.productName,
          'brand': list.items.first.brand,
          'quantity_value': list.items.first.quantity.value,
          'unit_price_cents': list.items.first.unitPrice.cents,
          'is_wholesale': list.items.first.isWholesale,
          'is_weight_based': list.items.first.isWeightBased,
          'price_per_kg_cents': list.items.first.pricePerKg?.cents,
          'weight_kg': list.items.first.weightKg?.value,
          'photo_url': list.items.first.photoUrl,
          'photo_captured_at': list.items.first.photoCapturedAt?.toIso8601String(),
          'substitute_item_id': list.items.first.substituteItemId,
          'position': list.items.first.position,
          'created_at': list.items.first.createdAt.toIso8601String(),
        }
      ];

      mockFilterBuilder.mockDataQueue = [listData, itemData];

      final result = await remoteRepository.getCurrentList();

      expect(result, isNotNull);
      expect(result!.id, list.id);
      expect(result.items.length, 1);
      expect(result.items.first.productName, 'Arroz');
    });

    test('returns null when no active list exists', () async {
      mockFilterBuilder.mockDataQueue = [<Map<String, dynamic>>[]];

      final result = await remoteRepository.getCurrentList();

      expect(result, isNull);
    });

    test('throws NetworkFailure on network exception', () async {
      mockFilterBuilder.forceError = const FormatException('No Internet');

      expect(
        () => remoteRepository.getCurrentList(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('saveCurrentList', () {
    test('inserts list and items in a batch', () async {
      final list = createTestList();
      mockFilterBuilder.mockDataQueue = [<Map<String, dynamic>>[], <Map<String, dynamic>>[]];

      await remoteRepository.saveCurrentList(list);

      verify(() => mockSupabaseClient.from('shopping_lists')).called(1);
      verify(() => mockSupabaseClient.from('shopping_items')).called(2); // Delete & Insert
    });

    test('throws NetworkFailure on standard network exception', () async {
      final list = createTestList();
      mockFilterBuilder.forceError = const FormatException('Bad JSON');

      expect(
        () => remoteRepository.saveCurrentList(list),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('deleteList', () {
    test('calls delete on list table and completes on success', () async {
      mockFilterBuilder.mockDataQueue = [[{'id': 'list-1'}]];

      await remoteRepository.deleteList('list-1');

      verify(() => mockQueryBuilder.delete()).called(1);
    });

    test('throws NotFoundFailure when list is not found', () async {
      mockFilterBuilder.mockDataQueue = [<Map<String, dynamic>>[]];

      expect(
        () => remoteRepository.deleteList('non-existent'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('finalizePurchase', () {
    test('calls Supabase finalize_purchase RPC', () async {
      final list = createTestList();
      when(() => mockSupabaseClient.rpc(
        'finalize_purchase',
        params: {'p_list_id': list.id},
      )).thenAnswer((_) => mockRpcBuilder);

      mockRpcBuilder.mockDataQueue = ['purchase-id'];

      await remoteRepository.finalizePurchase(list);

      verify(() => mockSupabaseClient.rpc(
        'finalize_purchase',
        params: {'p_list_id': list.id},
      )).called(1);
    });

    test('throws AuthFailure on AuthException during RPC', () async {
      final list = createTestList();
      when(() => mockSupabaseClient.rpc(
        'finalize_purchase',
        params: {'p_list_id': list.id},
      )).thenThrow(const AuthException('Permission denied'));

      expect(
        () => remoteRepository.finalizePurchase(list),
        throwsA(isA<AuthFailure>()),
      );
    });
  });
}
