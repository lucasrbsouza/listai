import 'package:drift/drift.dart';

class ShoppingListsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get marketName => text().nullable()();
  IntColumn get budgetGoalCents => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isTemplate => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get listId =>
      text().references(ShoppingListsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get productType => text()();
  TextColumn get productName => text()();
  TextColumn get brand => text().nullable()();
  RealColumn get quantityValue => real()();
  IntColumn get unitPriceCents => integer().nullable()();
  BoolColumn get isWholesale => boolean().withDefault(const Constant(false))();
  BoolColumn get isWeightBased =>
      boolean().withDefault(const Constant(false))();
  IntColumn get pricePerKgCents => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get photoCapturedAt => dateTime().nullable()();
  TextColumn get substituteItemId => text().nullable()();
  IntColumn get position => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchasesTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get listId => text()();
  TextColumn get marketName => text().nullable()();
  IntColumn get totalAmountCents => integer()();
  IntColumn get budgetGoalCents => integer().nullable()();
  BoolColumn get exceededBudget =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId =>
      text().references(PurchasesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get productType => text()();
  TextColumn get productName => text()();
  RealColumn get quantityValue => real()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get totalPriceCents => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
