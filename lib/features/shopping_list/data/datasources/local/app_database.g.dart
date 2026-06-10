// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShoppingListsTableTable extends ShoppingListsTable
    with TableInfo<$ShoppingListsTableTable, ShoppingListsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketNameMeta = const VerificationMeta(
    'marketName',
  );
  @override
  late final GeneratedColumn<String> marketName = GeneratedColumn<String>(
    'market_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetGoalCentsMeta = const VerificationMeta(
    'budgetGoalCents',
  );
  @override
  late final GeneratedColumn<int> budgetGoalCents = GeneratedColumn<int>(
    'budget_goal_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isTemplateMeta = const VerificationMeta(
    'isTemplate',
  );
  @override
  late final GeneratedColumn<bool> isTemplate = GeneratedColumn<bool>(
    'is_template',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_template" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    marketName,
    budgetGoalCents,
    isCompleted,
    isTemplate,
    completedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_lists_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingListsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('market_name')) {
      context.handle(
        _marketNameMeta,
        marketName.isAcceptableOrUnknown(data['market_name']!, _marketNameMeta),
      );
    }
    if (data.containsKey('budget_goal_cents')) {
      context.handle(
        _budgetGoalCentsMeta,
        budgetGoalCents.isAcceptableOrUnknown(
          data['budget_goal_cents']!,
          _budgetGoalCentsMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_template')) {
      context.handle(
        _isTemplateMeta,
        isTemplate.isAcceptableOrUnknown(data['is_template']!, _isTemplateMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      marketName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market_name'],
      ),
      budgetGoalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_goal_cents'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      isTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_template'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShoppingListsTableTable createAlias(String alias) {
    return $ShoppingListsTableTable(attachedDatabase, alias);
  }
}

class ShoppingListsTableData extends DataClass
    implements Insertable<ShoppingListsTableData> {
  final String id;
  final String? userId;
  final String name;
  final String? marketName;
  final int? budgetGoalCents;
  final bool isCompleted;
  final bool isTemplate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ShoppingListsTableData({
    required this.id,
    this.userId,
    required this.name,
    this.marketName,
    this.budgetGoalCents,
    required this.isCompleted,
    required this.isTemplate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || marketName != null) {
      map['market_name'] = Variable<String>(marketName);
    }
    if (!nullToAbsent || budgetGoalCents != null) {
      map['budget_goal_cents'] = Variable<int>(budgetGoalCents);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_template'] = Variable<bool>(isTemplate);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShoppingListsTableCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListsTableCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      name: Value(name),
      marketName: marketName == null && nullToAbsent
          ? const Value.absent()
          : Value(marketName),
      budgetGoalCents: budgetGoalCents == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetGoalCents),
      isCompleted: Value(isCompleted),
      isTemplate: Value(isTemplate),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShoppingListsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListsTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      marketName: serializer.fromJson<String?>(json['marketName']),
      budgetGoalCents: serializer.fromJson<int?>(json['budgetGoalCents']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isTemplate: serializer.fromJson<bool>(json['isTemplate']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'marketName': serializer.toJson<String?>(marketName),
      'budgetGoalCents': serializer.toJson<int?>(budgetGoalCents),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isTemplate': serializer.toJson<bool>(isTemplate),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShoppingListsTableData copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? name,
    Value<String?> marketName = const Value.absent(),
    Value<int?> budgetGoalCents = const Value.absent(),
    bool? isCompleted,
    bool? isTemplate,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ShoppingListsTableData(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    name: name ?? this.name,
    marketName: marketName.present ? marketName.value : this.marketName,
    budgetGoalCents: budgetGoalCents.present
        ? budgetGoalCents.value
        : this.budgetGoalCents,
    isCompleted: isCompleted ?? this.isCompleted,
    isTemplate: isTemplate ?? this.isTemplate,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ShoppingListsTableData copyWithCompanion(ShoppingListsTableCompanion data) {
    return ShoppingListsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      marketName: data.marketName.present
          ? data.marketName.value
          : this.marketName,
      budgetGoalCents: data.budgetGoalCents.present
          ? data.budgetGoalCents.value
          : this.budgetGoalCents,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      isTemplate: data.isTemplate.present
          ? data.isTemplate.value
          : this.isTemplate,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('marketName: $marketName, ')
          ..write('budgetGoalCents: $budgetGoalCents, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isTemplate: $isTemplate, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    marketName,
    budgetGoalCents,
    isCompleted,
    isTemplate,
    completedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.marketName == this.marketName &&
          other.budgetGoalCents == this.budgetGoalCents &&
          other.isCompleted == this.isCompleted &&
          other.isTemplate == this.isTemplate &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShoppingListsTableCompanion
    extends UpdateCompanion<ShoppingListsTableData> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> name;
  final Value<String?> marketName;
  final Value<int?> budgetGoalCents;
  final Value<bool> isCompleted;
  final Value<bool> isTemplate;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShoppingListsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.marketName = const Value.absent(),
    this.budgetGoalCents = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isTemplate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListsTableCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    this.marketName = const Value.absent(),
    this.budgetGoalCents = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isTemplate = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ShoppingListsTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? marketName,
    Expression<int>? budgetGoalCents,
    Expression<bool>? isCompleted,
    Expression<bool>? isTemplate,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (marketName != null) 'market_name': marketName,
      if (budgetGoalCents != null) 'budget_goal_cents': budgetGoalCents,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isTemplate != null) 'is_template': isTemplate,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? name,
    Value<String?>? marketName,
    Value<int?>? budgetGoalCents,
    Value<bool>? isCompleted,
    Value<bool>? isTemplate,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ShoppingListsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      marketName: marketName ?? this.marketName,
      budgetGoalCents: budgetGoalCents ?? this.budgetGoalCents,
      isCompleted: isCompleted ?? this.isCompleted,
      isTemplate: isTemplate ?? this.isTemplate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (marketName.present) {
      map['market_name'] = Variable<String>(marketName.value);
    }
    if (budgetGoalCents.present) {
      map['budget_goal_cents'] = Variable<int>(budgetGoalCents.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isTemplate.present) {
      map['is_template'] = Variable<bool>(isTemplate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('marketName: $marketName, ')
          ..write('budgetGoalCents: $budgetGoalCents, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isTemplate: $isTemplate, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingItemsTableTable extends ShoppingItemsTable
    with TableInfo<$ShoppingItemsTableTable, ShoppingItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shopping_lists_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productTypeMeta = const VerificationMeta(
    'productType',
  );
  @override
  late final GeneratedColumn<String> productType = GeneratedColumn<String>(
    'product_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityValueMeta = const VerificationMeta(
    'quantityValue',
  );
  @override
  late final GeneratedColumn<double> quantityValue = GeneratedColumn<double>(
    'quantity_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isWholesaleMeta = const VerificationMeta(
    'isWholesale',
  );
  @override
  late final GeneratedColumn<bool> isWholesale = GeneratedColumn<bool>(
    'is_wholesale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_wholesale" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWeightBasedMeta = const VerificationMeta(
    'isWeightBased',
  );
  @override
  late final GeneratedColumn<bool> isWeightBased = GeneratedColumn<bool>(
    'is_weight_based',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_weight_based" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pricePerKgCentsMeta = const VerificationMeta(
    'pricePerKgCents',
  );
  @override
  late final GeneratedColumn<int> pricePerKgCents = GeneratedColumn<int>(
    'price_per_kg_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoCapturedAtMeta = const VerificationMeta(
    'photoCapturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> photoCapturedAt =
      GeneratedColumn<DateTime>(
        'photo_captured_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _substituteItemIdMeta = const VerificationMeta(
    'substituteItemId',
  );
  @override
  late final GeneratedColumn<String> substituteItemId = GeneratedColumn<String>(
    'substitute_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    productType,
    productName,
    brand,
    quantityValue,
    unitPriceCents,
    isWholesale,
    isWeightBased,
    pricePerKgCents,
    weightKg,
    photoUrl,
    photoCapturedAt,
    substituteItemId,
    position,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('product_type')) {
      context.handle(
        _productTypeMeta,
        productType.isAcceptableOrUnknown(
          data['product_type']!,
          _productTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productTypeMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('quantity_value')) {
      context.handle(
        _quantityValueMeta,
        quantityValue.isAcceptableOrUnknown(
          data['quantity_value']!,
          _quantityValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityValueMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('is_wholesale')) {
      context.handle(
        _isWholesaleMeta,
        isWholesale.isAcceptableOrUnknown(
          data['is_wholesale']!,
          _isWholesaleMeta,
        ),
      );
    }
    if (data.containsKey('is_weight_based')) {
      context.handle(
        _isWeightBasedMeta,
        isWeightBased.isAcceptableOrUnknown(
          data['is_weight_based']!,
          _isWeightBasedMeta,
        ),
      );
    }
    if (data.containsKey('price_per_kg_cents')) {
      context.handle(
        _pricePerKgCentsMeta,
        pricePerKgCents.isAcceptableOrUnknown(
          data['price_per_kg_cents']!,
          _pricePerKgCentsMeta,
        ),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('photo_captured_at')) {
      context.handle(
        _photoCapturedAtMeta,
        photoCapturedAt.isAcceptableOrUnknown(
          data['photo_captured_at']!,
          _photoCapturedAtMeta,
        ),
      );
    }
    if (data.containsKey('substitute_item_id')) {
      context.handle(
        _substituteItemIdMeta,
        substituteItemId.isAcceptableOrUnknown(
          data['substitute_item_id']!,
          _substituteItemIdMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      productType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_type'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      quantityValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_value'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      ),
      isWholesale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_wholesale'],
      )!,
      isWeightBased: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_weight_based'],
      )!,
      pricePerKgCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_kg_cents'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      photoCapturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}photo_captured_at'],
      ),
      substituteItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substitute_item_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ShoppingItemsTableTable createAlias(String alias) {
    return $ShoppingItemsTableTable(attachedDatabase, alias);
  }
}

class ShoppingItemsTableData extends DataClass
    implements Insertable<ShoppingItemsTableData> {
  final String id;
  final String listId;
  final String productType;
  final String productName;
  final String? brand;
  final double quantityValue;
  final int? unitPriceCents;
  final bool isWholesale;
  final bool isWeightBased;
  final int? pricePerKgCents;
  final double? weightKg;
  final String? photoUrl;
  final DateTime? photoCapturedAt;
  final String? substituteItemId;
  final int position;
  final DateTime createdAt;
  const ShoppingItemsTableData({
    required this.id,
    required this.listId,
    required this.productType,
    required this.productName,
    this.brand,
    required this.quantityValue,
    this.unitPriceCents,
    required this.isWholesale,
    required this.isWeightBased,
    this.pricePerKgCents,
    this.weightKg,
    this.photoUrl,
    this.photoCapturedAt,
    this.substituteItemId,
    required this.position,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    map['product_type'] = Variable<String>(productType);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['quantity_value'] = Variable<double>(quantityValue);
    if (!nullToAbsent || unitPriceCents != null) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents);
    }
    map['is_wholesale'] = Variable<bool>(isWholesale);
    map['is_weight_based'] = Variable<bool>(isWeightBased);
    if (!nullToAbsent || pricePerKgCents != null) {
      map['price_per_kg_cents'] = Variable<int>(pricePerKgCents);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || photoCapturedAt != null) {
      map['photo_captured_at'] = Variable<DateTime>(photoCapturedAt);
    }
    if (!nullToAbsent || substituteItemId != null) {
      map['substitute_item_id'] = Variable<String>(substituteItemId);
    }
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShoppingItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ShoppingItemsTableCompanion(
      id: Value(id),
      listId: Value(listId),
      productType: Value(productType),
      productName: Value(productName),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      quantityValue: Value(quantityValue),
      unitPriceCents: unitPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPriceCents),
      isWholesale: Value(isWholesale),
      isWeightBased: Value(isWeightBased),
      pricePerKgCents: pricePerKgCents == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerKgCents),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      photoCapturedAt: photoCapturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(photoCapturedAt),
      substituteItemId: substituteItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(substituteItemId),
      position: Value(position),
      createdAt: Value(createdAt),
    );
  }

  factory ShoppingItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      productType: serializer.fromJson<String>(json['productType']),
      productName: serializer.fromJson<String>(json['productName']),
      brand: serializer.fromJson<String?>(json['brand']),
      quantityValue: serializer.fromJson<double>(json['quantityValue']),
      unitPriceCents: serializer.fromJson<int?>(json['unitPriceCents']),
      isWholesale: serializer.fromJson<bool>(json['isWholesale']),
      isWeightBased: serializer.fromJson<bool>(json['isWeightBased']),
      pricePerKgCents: serializer.fromJson<int?>(json['pricePerKgCents']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      photoCapturedAt: serializer.fromJson<DateTime?>(json['photoCapturedAt']),
      substituteItemId: serializer.fromJson<String?>(json['substituteItemId']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'productType': serializer.toJson<String>(productType),
      'productName': serializer.toJson<String>(productName),
      'brand': serializer.toJson<String?>(brand),
      'quantityValue': serializer.toJson<double>(quantityValue),
      'unitPriceCents': serializer.toJson<int?>(unitPriceCents),
      'isWholesale': serializer.toJson<bool>(isWholesale),
      'isWeightBased': serializer.toJson<bool>(isWeightBased),
      'pricePerKgCents': serializer.toJson<int?>(pricePerKgCents),
      'weightKg': serializer.toJson<double?>(weightKg),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'photoCapturedAt': serializer.toJson<DateTime?>(photoCapturedAt),
      'substituteItemId': serializer.toJson<String?>(substituteItemId),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShoppingItemsTableData copyWith({
    String? id,
    String? listId,
    String? productType,
    String? productName,
    Value<String?> brand = const Value.absent(),
    double? quantityValue,
    Value<int?> unitPriceCents = const Value.absent(),
    bool? isWholesale,
    bool? isWeightBased,
    Value<int?> pricePerKgCents = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    Value<DateTime?> photoCapturedAt = const Value.absent(),
    Value<String?> substituteItemId = const Value.absent(),
    int? position,
    DateTime? createdAt,
  }) => ShoppingItemsTableData(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    productType: productType ?? this.productType,
    productName: productName ?? this.productName,
    brand: brand.present ? brand.value : this.brand,
    quantityValue: quantityValue ?? this.quantityValue,
    unitPriceCents: unitPriceCents.present
        ? unitPriceCents.value
        : this.unitPriceCents,
    isWholesale: isWholesale ?? this.isWholesale,
    isWeightBased: isWeightBased ?? this.isWeightBased,
    pricePerKgCents: pricePerKgCents.present
        ? pricePerKgCents.value
        : this.pricePerKgCents,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    photoCapturedAt: photoCapturedAt.present
        ? photoCapturedAt.value
        : this.photoCapturedAt,
    substituteItemId: substituteItemId.present
        ? substituteItemId.value
        : this.substituteItemId,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
  );
  ShoppingItemsTableData copyWithCompanion(ShoppingItemsTableCompanion data) {
    return ShoppingItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      productType: data.productType.present
          ? data.productType.value
          : this.productType,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      brand: data.brand.present ? data.brand.value : this.brand,
      quantityValue: data.quantityValue.present
          ? data.quantityValue.value
          : this.quantityValue,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      isWholesale: data.isWholesale.present
          ? data.isWholesale.value
          : this.isWholesale,
      isWeightBased: data.isWeightBased.present
          ? data.isWeightBased.value
          : this.isWeightBased,
      pricePerKgCents: data.pricePerKgCents.present
          ? data.pricePerKgCents.value
          : this.pricePerKgCents,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      photoCapturedAt: data.photoCapturedAt.present
          ? data.photoCapturedAt.value
          : this.photoCapturedAt,
      substituteItemId: data.substituteItemId.present
          ? data.substituteItemId.value
          : this.substituteItemId,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemsTableData(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('productType: $productType, ')
          ..write('productName: $productName, ')
          ..write('brand: $brand, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('isWholesale: $isWholesale, ')
          ..write('isWeightBased: $isWeightBased, ')
          ..write('pricePerKgCents: $pricePerKgCents, ')
          ..write('weightKg: $weightKg, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoCapturedAt: $photoCapturedAt, ')
          ..write('substituteItemId: $substituteItemId, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    productType,
    productName,
    brand,
    quantityValue,
    unitPriceCents,
    isWholesale,
    isWeightBased,
    pricePerKgCents,
    weightKg,
    photoUrl,
    photoCapturedAt,
    substituteItemId,
    position,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingItemsTableData &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.productType == this.productType &&
          other.productName == this.productName &&
          other.brand == this.brand &&
          other.quantityValue == this.quantityValue &&
          other.unitPriceCents == this.unitPriceCents &&
          other.isWholesale == this.isWholesale &&
          other.isWeightBased == this.isWeightBased &&
          other.pricePerKgCents == this.pricePerKgCents &&
          other.weightKg == this.weightKg &&
          other.photoUrl == this.photoUrl &&
          other.photoCapturedAt == this.photoCapturedAt &&
          other.substituteItemId == this.substituteItemId &&
          other.position == this.position &&
          other.createdAt == this.createdAt);
}

class ShoppingItemsTableCompanion
    extends UpdateCompanion<ShoppingItemsTableData> {
  final Value<String> id;
  final Value<String> listId;
  final Value<String> productType;
  final Value<String> productName;
  final Value<String?> brand;
  final Value<double> quantityValue;
  final Value<int?> unitPriceCents;
  final Value<bool> isWholesale;
  final Value<bool> isWeightBased;
  final Value<int?> pricePerKgCents;
  final Value<double?> weightKg;
  final Value<String?> photoUrl;
  final Value<DateTime?> photoCapturedAt;
  final Value<String?> substituteItemId;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ShoppingItemsTableCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.productType = const Value.absent(),
    this.productName = const Value.absent(),
    this.brand = const Value.absent(),
    this.quantityValue = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.isWholesale = const Value.absent(),
    this.isWeightBased = const Value.absent(),
    this.pricePerKgCents = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.photoCapturedAt = const Value.absent(),
    this.substituteItemId = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingItemsTableCompanion.insert({
    required String id,
    required String listId,
    required String productType,
    required String productName,
    this.brand = const Value.absent(),
    required double quantityValue,
    this.unitPriceCents = const Value.absent(),
    this.isWholesale = const Value.absent(),
    this.isWeightBased = const Value.absent(),
    this.pricePerKgCents = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.photoCapturedAt = const Value.absent(),
    this.substituteItemId = const Value.absent(),
    required int position,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       listId = Value(listId),
       productType = Value(productType),
       productName = Value(productName),
       quantityValue = Value(quantityValue),
       position = Value(position),
       createdAt = Value(createdAt);
  static Insertable<ShoppingItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? productType,
    Expression<String>? productName,
    Expression<String>? brand,
    Expression<double>? quantityValue,
    Expression<int>? unitPriceCents,
    Expression<bool>? isWholesale,
    Expression<bool>? isWeightBased,
    Expression<int>? pricePerKgCents,
    Expression<double>? weightKg,
    Expression<String>? photoUrl,
    Expression<DateTime>? photoCapturedAt,
    Expression<String>? substituteItemId,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (productType != null) 'product_type': productType,
      if (productName != null) 'product_name': productName,
      if (brand != null) 'brand': brand,
      if (quantityValue != null) 'quantity_value': quantityValue,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (isWholesale != null) 'is_wholesale': isWholesale,
      if (isWeightBased != null) 'is_weight_based': isWeightBased,
      if (pricePerKgCents != null) 'price_per_kg_cents': pricePerKgCents,
      if (weightKg != null) 'weight_kg': weightKg,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (photoCapturedAt != null) 'photo_captured_at': photoCapturedAt,
      if (substituteItemId != null) 'substitute_item_id': substituteItemId,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? listId,
    Value<String>? productType,
    Value<String>? productName,
    Value<String?>? brand,
    Value<double>? quantityValue,
    Value<int?>? unitPriceCents,
    Value<bool>? isWholesale,
    Value<bool>? isWeightBased,
    Value<int?>? pricePerKgCents,
    Value<double?>? weightKg,
    Value<String?>? photoUrl,
    Value<DateTime?>? photoCapturedAt,
    Value<String?>? substituteItemId,
    Value<int>? position,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ShoppingItemsTableCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      productType: productType ?? this.productType,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      quantityValue: quantityValue ?? this.quantityValue,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      isWholesale: isWholesale ?? this.isWholesale,
      isWeightBased: isWeightBased ?? this.isWeightBased,
      pricePerKgCents: pricePerKgCents ?? this.pricePerKgCents,
      weightKg: weightKg ?? this.weightKg,
      photoUrl: photoUrl ?? this.photoUrl,
      photoCapturedAt: photoCapturedAt ?? this.photoCapturedAt,
      substituteItemId: substituteItemId ?? this.substituteItemId,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (productType.present) {
      map['product_type'] = Variable<String>(productType.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (quantityValue.present) {
      map['quantity_value'] = Variable<double>(quantityValue.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (isWholesale.present) {
      map['is_wholesale'] = Variable<bool>(isWholesale.value);
    }
    if (isWeightBased.present) {
      map['is_weight_based'] = Variable<bool>(isWeightBased.value);
    }
    if (pricePerKgCents.present) {
      map['price_per_kg_cents'] = Variable<int>(pricePerKgCents.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (photoCapturedAt.present) {
      map['photo_captured_at'] = Variable<DateTime>(photoCapturedAt.value);
    }
    if (substituteItemId.present) {
      map['substitute_item_id'] = Variable<String>(substituteItemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('productType: $productType, ')
          ..write('productName: $productName, ')
          ..write('brand: $brand, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('isWholesale: $isWholesale, ')
          ..write('isWeightBased: $isWeightBased, ')
          ..write('pricePerKgCents: $pricePerKgCents, ')
          ..write('weightKg: $weightKg, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoCapturedAt: $photoCapturedAt, ')
          ..write('substituteItemId: $substituteItemId, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTableTable extends PurchasesTable
    with TableInfo<$PurchasesTableTable, PurchasesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketNameMeta = const VerificationMeta(
    'marketName',
  );
  @override
  late final GeneratedColumn<String> marketName = GeneratedColumn<String>(
    'market_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountCentsMeta = const VerificationMeta(
    'totalAmountCents',
  );
  @override
  late final GeneratedColumn<int> totalAmountCents = GeneratedColumn<int>(
    'total_amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetGoalCentsMeta = const VerificationMeta(
    'budgetGoalCents',
  );
  @override
  late final GeneratedColumn<int> budgetGoalCents = GeneratedColumn<int>(
    'budget_goal_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exceededBudgetMeta = const VerificationMeta(
    'exceededBudget',
  );
  @override
  late final GeneratedColumn<bool> exceededBudget = GeneratedColumn<bool>(
    'exceeded_budget',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exceeded_budget" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    listId,
    marketName,
    totalAmountCents,
    budgetGoalCents,
    exceededBudget,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchasesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('market_name')) {
      context.handle(
        _marketNameMeta,
        marketName.isAcceptableOrUnknown(data['market_name']!, _marketNameMeta),
      );
    }
    if (data.containsKey('total_amount_cents')) {
      context.handle(
        _totalAmountCentsMeta,
        totalAmountCents.isAcceptableOrUnknown(
          data['total_amount_cents']!,
          _totalAmountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountCentsMeta);
    }
    if (data.containsKey('budget_goal_cents')) {
      context.handle(
        _budgetGoalCentsMeta,
        budgetGoalCents.isAcceptableOrUnknown(
          data['budget_goal_cents']!,
          _budgetGoalCentsMeta,
        ),
      );
    }
    if (data.containsKey('exceeded_budget')) {
      context.handle(
        _exceededBudgetMeta,
        exceededBudget.isAcceptableOrUnknown(
          data['exceeded_budget']!,
          _exceededBudgetMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchasesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchasesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      marketName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market_name'],
      ),
      totalAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount_cents'],
      )!,
      budgetGoalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_goal_cents'],
      ),
      exceededBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exceeded_budget'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $PurchasesTableTable createAlias(String alias) {
    return $PurchasesTableTable(attachedDatabase, alias);
  }
}

class PurchasesTableData extends DataClass
    implements Insertable<PurchasesTableData> {
  final String id;
  final String userId;
  final String listId;
  final String? marketName;
  final int totalAmountCents;
  final int? budgetGoalCents;
  final bool exceededBudget;
  final DateTime completedAt;
  const PurchasesTableData({
    required this.id,
    required this.userId,
    required this.listId,
    this.marketName,
    required this.totalAmountCents,
    this.budgetGoalCents,
    required this.exceededBudget,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['list_id'] = Variable<String>(listId);
    if (!nullToAbsent || marketName != null) {
      map['market_name'] = Variable<String>(marketName);
    }
    map['total_amount_cents'] = Variable<int>(totalAmountCents);
    if (!nullToAbsent || budgetGoalCents != null) {
      map['budget_goal_cents'] = Variable<int>(budgetGoalCents);
    }
    map['exceeded_budget'] = Variable<bool>(exceededBudget);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  PurchasesTableCompanion toCompanion(bool nullToAbsent) {
    return PurchasesTableCompanion(
      id: Value(id),
      userId: Value(userId),
      listId: Value(listId),
      marketName: marketName == null && nullToAbsent
          ? const Value.absent()
          : Value(marketName),
      totalAmountCents: Value(totalAmountCents),
      budgetGoalCents: budgetGoalCents == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetGoalCents),
      exceededBudget: Value(exceededBudget),
      completedAt: Value(completedAt),
    );
  }

  factory PurchasesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchasesTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      listId: serializer.fromJson<String>(json['listId']),
      marketName: serializer.fromJson<String?>(json['marketName']),
      totalAmountCents: serializer.fromJson<int>(json['totalAmountCents']),
      budgetGoalCents: serializer.fromJson<int?>(json['budgetGoalCents']),
      exceededBudget: serializer.fromJson<bool>(json['exceededBudget']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'listId': serializer.toJson<String>(listId),
      'marketName': serializer.toJson<String?>(marketName),
      'totalAmountCents': serializer.toJson<int>(totalAmountCents),
      'budgetGoalCents': serializer.toJson<int?>(budgetGoalCents),
      'exceededBudget': serializer.toJson<bool>(exceededBudget),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  PurchasesTableData copyWith({
    String? id,
    String? userId,
    String? listId,
    Value<String?> marketName = const Value.absent(),
    int? totalAmountCents,
    Value<int?> budgetGoalCents = const Value.absent(),
    bool? exceededBudget,
    DateTime? completedAt,
  }) => PurchasesTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    listId: listId ?? this.listId,
    marketName: marketName.present ? marketName.value : this.marketName,
    totalAmountCents: totalAmountCents ?? this.totalAmountCents,
    budgetGoalCents: budgetGoalCents.present
        ? budgetGoalCents.value
        : this.budgetGoalCents,
    exceededBudget: exceededBudget ?? this.exceededBudget,
    completedAt: completedAt ?? this.completedAt,
  );
  PurchasesTableData copyWithCompanion(PurchasesTableCompanion data) {
    return PurchasesTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      listId: data.listId.present ? data.listId.value : this.listId,
      marketName: data.marketName.present
          ? data.marketName.value
          : this.marketName,
      totalAmountCents: data.totalAmountCents.present
          ? data.totalAmountCents.value
          : this.totalAmountCents,
      budgetGoalCents: data.budgetGoalCents.present
          ? data.budgetGoalCents.value
          : this.budgetGoalCents,
      exceededBudget: data.exceededBudget.present
          ? data.exceededBudget.value
          : this.exceededBudget,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('listId: $listId, ')
          ..write('marketName: $marketName, ')
          ..write('totalAmountCents: $totalAmountCents, ')
          ..write('budgetGoalCents: $budgetGoalCents, ')
          ..write('exceededBudget: $exceededBudget, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    listId,
    marketName,
    totalAmountCents,
    budgetGoalCents,
    exceededBudget,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchasesTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.listId == this.listId &&
          other.marketName == this.marketName &&
          other.totalAmountCents == this.totalAmountCents &&
          other.budgetGoalCents == this.budgetGoalCents &&
          other.exceededBudget == this.exceededBudget &&
          other.completedAt == this.completedAt);
}

class PurchasesTableCompanion extends UpdateCompanion<PurchasesTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> listId;
  final Value<String?> marketName;
  final Value<int> totalAmountCents;
  final Value<int?> budgetGoalCents;
  final Value<bool> exceededBudget;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const PurchasesTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.listId = const Value.absent(),
    this.marketName = const Value.absent(),
    this.totalAmountCents = const Value.absent(),
    this.budgetGoalCents = const Value.absent(),
    this.exceededBudget = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesTableCompanion.insert({
    required String id,
    required String userId,
    required String listId,
    this.marketName = const Value.absent(),
    required int totalAmountCents,
    this.budgetGoalCents = const Value.absent(),
    this.exceededBudget = const Value.absent(),
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       listId = Value(listId),
       totalAmountCents = Value(totalAmountCents),
       completedAt = Value(completedAt);
  static Insertable<PurchasesTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? listId,
    Expression<String>? marketName,
    Expression<int>? totalAmountCents,
    Expression<int>? budgetGoalCents,
    Expression<bool>? exceededBudget,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (listId != null) 'list_id': listId,
      if (marketName != null) 'market_name': marketName,
      if (totalAmountCents != null) 'total_amount_cents': totalAmountCents,
      if (budgetGoalCents != null) 'budget_goal_cents': budgetGoalCents,
      if (exceededBudget != null) 'exceeded_budget': exceededBudget,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? listId,
    Value<String?>? marketName,
    Value<int>? totalAmountCents,
    Value<int?>? budgetGoalCents,
    Value<bool>? exceededBudget,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return PurchasesTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listId: listId ?? this.listId,
      marketName: marketName ?? this.marketName,
      totalAmountCents: totalAmountCents ?? this.totalAmountCents,
      budgetGoalCents: budgetGoalCents ?? this.budgetGoalCents,
      exceededBudget: exceededBudget ?? this.exceededBudget,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (marketName.present) {
      map['market_name'] = Variable<String>(marketName.value);
    }
    if (totalAmountCents.present) {
      map['total_amount_cents'] = Variable<int>(totalAmountCents.value);
    }
    if (budgetGoalCents.present) {
      map['budget_goal_cents'] = Variable<int>(budgetGoalCents.value);
    }
    if (exceededBudget.present) {
      map['exceeded_budget'] = Variable<bool>(exceededBudget.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('listId: $listId, ')
          ..write('marketName: $marketName, ')
          ..write('totalAmountCents: $totalAmountCents, ')
          ..write('budgetGoalCents: $budgetGoalCents, ')
          ..write('exceededBudget: $exceededBudget, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseItemsTableTable extends PurchaseItemsTable
    with TableInfo<$PurchaseItemsTableTable, PurchaseItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchases_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productTypeMeta = const VerificationMeta(
    'productType',
  );
  @override
  late final GeneratedColumn<String> productType = GeneratedColumn<String>(
    'product_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityValueMeta = const VerificationMeta(
    'quantityValue',
  );
  @override
  late final GeneratedColumn<double> quantityValue = GeneratedColumn<double>(
    'quantity_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPriceCentsMeta = const VerificationMeta(
    'totalPriceCents',
  );
  @override
  late final GeneratedColumn<int> totalPriceCents = GeneratedColumn<int>(
    'total_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseId,
    productType,
    productName,
    quantityValue,
    unitPriceCents,
    totalPriceCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('product_type')) {
      context.handle(
        _productTypeMeta,
        productType.isAcceptableOrUnknown(
          data['product_type']!,
          _productTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productTypeMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity_value')) {
      context.handle(
        _quantityValueMeta,
        quantityValue.isAcceptableOrUnknown(
          data['quantity_value']!,
          _quantityValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityValueMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('total_price_cents')) {
      context.handle(
        _totalPriceCentsMeta,
        totalPriceCents.isAcceptableOrUnknown(
          data['total_price_cents']!,
          _totalPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPriceCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      productType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_type'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantityValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_value'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      totalPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_price_cents'],
      )!,
    );
  }

  @override
  $PurchaseItemsTableTable createAlias(String alias) {
    return $PurchaseItemsTableTable(attachedDatabase, alias);
  }
}

class PurchaseItemsTableData extends DataClass
    implements Insertable<PurchaseItemsTableData> {
  final String id;
  final String purchaseId;
  final String productType;
  final String productName;
  final double quantityValue;
  final int unitPriceCents;
  final int totalPriceCents;
  const PurchaseItemsTableData({
    required this.id,
    required this.purchaseId,
    required this.productType,
    required this.productName,
    required this.quantityValue,
    required this.unitPriceCents,
    required this.totalPriceCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['product_type'] = Variable<String>(productType);
    map['product_name'] = Variable<String>(productName);
    map['quantity_value'] = Variable<double>(quantityValue);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['total_price_cents'] = Variable<int>(totalPriceCents);
    return map;
  }

  PurchaseItemsTableCompanion toCompanion(bool nullToAbsent) {
    return PurchaseItemsTableCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      productType: Value(productType),
      productName: Value(productName),
      quantityValue: Value(quantityValue),
      unitPriceCents: Value(unitPriceCents),
      totalPriceCents: Value(totalPriceCents),
    );
  }

  factory PurchaseItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      productType: serializer.fromJson<String>(json['productType']),
      productName: serializer.fromJson<String>(json['productName']),
      quantityValue: serializer.fromJson<double>(json['quantityValue']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      totalPriceCents: serializer.fromJson<int>(json['totalPriceCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'productType': serializer.toJson<String>(productType),
      'productName': serializer.toJson<String>(productName),
      'quantityValue': serializer.toJson<double>(quantityValue),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'totalPriceCents': serializer.toJson<int>(totalPriceCents),
    };
  }

  PurchaseItemsTableData copyWith({
    String? id,
    String? purchaseId,
    String? productType,
    String? productName,
    double? quantityValue,
    int? unitPriceCents,
    int? totalPriceCents,
  }) => PurchaseItemsTableData(
    id: id ?? this.id,
    purchaseId: purchaseId ?? this.purchaseId,
    productType: productType ?? this.productType,
    productName: productName ?? this.productName,
    quantityValue: quantityValue ?? this.quantityValue,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    totalPriceCents: totalPriceCents ?? this.totalPriceCents,
  );
  PurchaseItemsTableData copyWithCompanion(PurchaseItemsTableCompanion data) {
    return PurchaseItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      productType: data.productType.present
          ? data.productType.value
          : this.productType,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantityValue: data.quantityValue.present
          ? data.quantityValue.value
          : this.quantityValue,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      totalPriceCents: data.totalPriceCents.present
          ? data.totalPriceCents.value
          : this.totalPriceCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemsTableData(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productType: $productType, ')
          ..write('productName: $productName, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalPriceCents: $totalPriceCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseId,
    productType,
    productName,
    quantityValue,
    unitPriceCents,
    totalPriceCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseItemsTableData &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.productType == this.productType &&
          other.productName == this.productName &&
          other.quantityValue == this.quantityValue &&
          other.unitPriceCents == this.unitPriceCents &&
          other.totalPriceCents == this.totalPriceCents);
}

class PurchaseItemsTableCompanion
    extends UpdateCompanion<PurchaseItemsTableData> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String> productType;
  final Value<String> productName;
  final Value<double> quantityValue;
  final Value<int> unitPriceCents;
  final Value<int> totalPriceCents;
  final Value<int> rowid;
  const PurchaseItemsTableCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.productType = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantityValue = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.totalPriceCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseItemsTableCompanion.insert({
    required String id,
    required String purchaseId,
    required String productType,
    required String productName,
    required double quantityValue,
    required int unitPriceCents,
    required int totalPriceCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseId = Value(purchaseId),
       productType = Value(productType),
       productName = Value(productName),
       quantityValue = Value(quantityValue),
       unitPriceCents = Value(unitPriceCents),
       totalPriceCents = Value(totalPriceCents);
  static Insertable<PurchaseItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? productType,
    Expression<String>? productName,
    Expression<double>? quantityValue,
    Expression<int>? unitPriceCents,
    Expression<int>? totalPriceCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productType != null) 'product_type': productType,
      if (productName != null) 'product_name': productName,
      if (quantityValue != null) 'quantity_value': quantityValue,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (totalPriceCents != null) 'total_price_cents': totalPriceCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseId,
    Value<String>? productType,
    Value<String>? productName,
    Value<double>? quantityValue,
    Value<int>? unitPriceCents,
    Value<int>? totalPriceCents,
    Value<int>? rowid,
  }) {
    return PurchaseItemsTableCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productType: productType ?? this.productType,
      productName: productName ?? this.productName,
      quantityValue: quantityValue ?? this.quantityValue,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      totalPriceCents: totalPriceCents ?? this.totalPriceCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (productType.present) {
      map['product_type'] = Variable<String>(productType.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantityValue.present) {
      map['quantity_value'] = Variable<double>(quantityValue.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (totalPriceCents.present) {
      map['total_price_cents'] = Variable<int>(totalPriceCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productType: $productType, ')
          ..write('productName: $productName, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalPriceCents: $totalPriceCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShoppingListsTableTable shoppingListsTable =
      $ShoppingListsTableTable(this);
  late final $ShoppingItemsTableTable shoppingItemsTable =
      $ShoppingItemsTableTable(this);
  late final $PurchasesTableTable purchasesTable = $PurchasesTableTable(this);
  late final $PurchaseItemsTableTable purchaseItemsTable =
      $PurchaseItemsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shoppingListsTable,
    shoppingItemsTable,
    purchasesTable,
    purchaseItemsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_lists_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shopping_items_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'purchases_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('purchase_items_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ShoppingListsTableTableCreateCompanionBuilder =
    ShoppingListsTableCompanion Function({
      required String id,
      Value<String?> userId,
      required String name,
      Value<String?> marketName,
      Value<int?> budgetGoalCents,
      Value<bool> isCompleted,
      Value<bool> isTemplate,
      Value<DateTime?> completedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ShoppingListsTableTableUpdateCompanionBuilder =
    ShoppingListsTableCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> name,
      Value<String?> marketName,
      Value<int?> budgetGoalCents,
      Value<bool> isCompleted,
      Value<bool> isTemplate,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ShoppingListsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ShoppingListsTableTable,
          ShoppingListsTableData
        > {
  $$ShoppingListsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ShoppingItemsTableTable,
    List<ShoppingItemsTableData>
  >
  _shoppingItemsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.shoppingItemsTable,
        aliasName: $_aliasNameGenerator(
          db.shoppingListsTable.id,
          db.shoppingItemsTable.listId,
        ),
      );

  $$ShoppingItemsTableTableProcessedTableManager get shoppingItemsTableRefs {
    final manager = $$ShoppingItemsTableTableTableManager(
      $_db,
      $_db.shoppingItemsTable,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _shoppingItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShoppingListsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingListsTableTable> {
  $$ShoppingListsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marketName => $composableBuilder(
    column: $table.marketName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetGoalCents => $composableBuilder(
    column: $table.budgetGoalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shoppingItemsTableRefs(
    Expression<bool> Function($$ShoppingItemsTableTableFilterComposer f) f,
  ) {
    final $$ShoppingItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shoppingItemsTable,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.shoppingItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShoppingListsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingListsTableTable> {
  $$ShoppingListsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marketName => $composableBuilder(
    column: $table.marketName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetGoalCents => $composableBuilder(
    column: $table.budgetGoalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShoppingListsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingListsTableTable> {
  $$ShoppingListsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get marketName => $composableBuilder(
    column: $table.marketName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get budgetGoalCents => $composableBuilder(
    column: $table.budgetGoalCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTemplate => $composableBuilder(
    column: $table.isTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> shoppingItemsTableRefs<T extends Object>(
    Expression<T> Function($$ShoppingItemsTableTableAnnotationComposer a) f,
  ) {
    final $$ShoppingItemsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.shoppingItemsTable,
          getReferencedColumn: (t) => t.listId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ShoppingItemsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.shoppingItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ShoppingListsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingListsTableTable,
          ShoppingListsTableData,
          $$ShoppingListsTableTableFilterComposer,
          $$ShoppingListsTableTableOrderingComposer,
          $$ShoppingListsTableTableAnnotationComposer,
          $$ShoppingListsTableTableCreateCompanionBuilder,
          $$ShoppingListsTableTableUpdateCompanionBuilder,
          (ShoppingListsTableData, $$ShoppingListsTableTableReferences),
          ShoppingListsTableData,
          PrefetchHooks Function({bool shoppingItemsTableRefs})
        > {
  $$ShoppingListsTableTableTableManager(
    _$AppDatabase db,
    $ShoppingListsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingListsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> marketName = const Value.absent(),
                Value<int?> budgetGoalCents = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isTemplate = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingListsTableCompanion(
                id: id,
                userId: userId,
                name: name,
                marketName: marketName,
                budgetGoalCents: budgetGoalCents,
                isCompleted: isCompleted,
                isTemplate: isTemplate,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String name,
                Value<String?> marketName = const Value.absent(),
                Value<int?> budgetGoalCents = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isTemplate = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShoppingListsTableCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                marketName: marketName,
                budgetGoalCents: budgetGoalCents,
                isCompleted: isCompleted,
                isTemplate: isTemplate,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShoppingListsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shoppingItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (shoppingItemsTableRefs) db.shoppingItemsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shoppingItemsTableRefs)
                    await $_getPrefetchedData<
                      ShoppingListsTableData,
                      $ShoppingListsTableTable,
                      ShoppingItemsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$ShoppingListsTableTableReferences
                          ._shoppingItemsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShoppingListsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).shoppingItemsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.listId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShoppingListsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingListsTableTable,
      ShoppingListsTableData,
      $$ShoppingListsTableTableFilterComposer,
      $$ShoppingListsTableTableOrderingComposer,
      $$ShoppingListsTableTableAnnotationComposer,
      $$ShoppingListsTableTableCreateCompanionBuilder,
      $$ShoppingListsTableTableUpdateCompanionBuilder,
      (ShoppingListsTableData, $$ShoppingListsTableTableReferences),
      ShoppingListsTableData,
      PrefetchHooks Function({bool shoppingItemsTableRefs})
    >;
typedef $$ShoppingItemsTableTableCreateCompanionBuilder =
    ShoppingItemsTableCompanion Function({
      required String id,
      required String listId,
      required String productType,
      required String productName,
      Value<String?> brand,
      required double quantityValue,
      Value<int?> unitPriceCents,
      Value<bool> isWholesale,
      Value<bool> isWeightBased,
      Value<int?> pricePerKgCents,
      Value<double?> weightKg,
      Value<String?> photoUrl,
      Value<DateTime?> photoCapturedAt,
      Value<String?> substituteItemId,
      required int position,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ShoppingItemsTableTableUpdateCompanionBuilder =
    ShoppingItemsTableCompanion Function({
      Value<String> id,
      Value<String> listId,
      Value<String> productType,
      Value<String> productName,
      Value<String?> brand,
      Value<double> quantityValue,
      Value<int?> unitPriceCents,
      Value<bool> isWholesale,
      Value<bool> isWeightBased,
      Value<int?> pricePerKgCents,
      Value<double?> weightKg,
      Value<String?> photoUrl,
      Value<DateTime?> photoCapturedAt,
      Value<String?> substituteItemId,
      Value<int> position,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ShoppingItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ShoppingItemsTableTable,
          ShoppingItemsTableData
        > {
  $$ShoppingItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ShoppingListsTableTable _listIdTable(_$AppDatabase db) =>
      db.shoppingListsTable.createAlias(
        $_aliasNameGenerator(
          db.shoppingItemsTable.listId,
          db.shoppingListsTable.id,
        ),
      );

  $$ShoppingListsTableTableProcessedTableManager get listId {
    final $_column = $_itemColumn<String>('list_id')!;

    final manager = $$ShoppingListsTableTableTableManager(
      $_db,
      $_db.shoppingListsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShoppingItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTableTable> {
  $$ShoppingItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityValue => $composableBuilder(
    column: $table.quantityValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWholesale => $composableBuilder(
    column: $table.isWholesale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWeightBased => $composableBuilder(
    column: $table.isWeightBased,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get photoCapturedAt => $composableBuilder(
    column: $table.photoCapturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get substituteItemId => $composableBuilder(
    column: $table.substituteItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ShoppingListsTableTableFilterComposer get listId {
    final $$ShoppingListsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.shoppingListsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingListsTableTableFilterComposer(
            $db: $db,
            $table: $db.shoppingListsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTableTable> {
  $$ShoppingItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityValue => $composableBuilder(
    column: $table.quantityValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWholesale => $composableBuilder(
    column: $table.isWholesale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWeightBased => $composableBuilder(
    column: $table.isWeightBased,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get photoCapturedAt => $composableBuilder(
    column: $table.photoCapturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get substituteItemId => $composableBuilder(
    column: $table.substituteItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShoppingListsTableTableOrderingComposer get listId {
    final $$ShoppingListsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.shoppingListsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingListsTableTableOrderingComposer(
            $db: $db,
            $table: $db.shoppingListsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTableTable> {
  $$ShoppingItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get quantityValue => $composableBuilder(
    column: $table.quantityValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWholesale => $composableBuilder(
    column: $table.isWholesale,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWeightBased => $composableBuilder(
    column: $table.isWeightBased,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get photoCapturedAt => $composableBuilder(
    column: $table.photoCapturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get substituteItemId => $composableBuilder(
    column: $table.substituteItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShoppingListsTableTableAnnotationComposer get listId {
    final $$ShoppingListsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.listId,
          referencedTable: $db.shoppingListsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ShoppingListsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.shoppingListsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ShoppingItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingItemsTableTable,
          ShoppingItemsTableData,
          $$ShoppingItemsTableTableFilterComposer,
          $$ShoppingItemsTableTableOrderingComposer,
          $$ShoppingItemsTableTableAnnotationComposer,
          $$ShoppingItemsTableTableCreateCompanionBuilder,
          $$ShoppingItemsTableTableUpdateCompanionBuilder,
          (ShoppingItemsTableData, $$ShoppingItemsTableTableReferences),
          ShoppingItemsTableData,
          PrefetchHooks Function({bool listId})
        > {
  $$ShoppingItemsTableTableTableManager(
    _$AppDatabase db,
    $ShoppingItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String> productType = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double> quantityValue = const Value.absent(),
                Value<int?> unitPriceCents = const Value.absent(),
                Value<bool> isWholesale = const Value.absent(),
                Value<bool> isWeightBased = const Value.absent(),
                Value<int?> pricePerKgCents = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime?> photoCapturedAt = const Value.absent(),
                Value<String?> substituteItemId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingItemsTableCompanion(
                id: id,
                listId: listId,
                productType: productType,
                productName: productName,
                brand: brand,
                quantityValue: quantityValue,
                unitPriceCents: unitPriceCents,
                isWholesale: isWholesale,
                isWeightBased: isWeightBased,
                pricePerKgCents: pricePerKgCents,
                weightKg: weightKg,
                photoUrl: photoUrl,
                photoCapturedAt: photoCapturedAt,
                substituteItemId: substituteItemId,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String listId,
                required String productType,
                required String productName,
                Value<String?> brand = const Value.absent(),
                required double quantityValue,
                Value<int?> unitPriceCents = const Value.absent(),
                Value<bool> isWholesale = const Value.absent(),
                Value<bool> isWeightBased = const Value.absent(),
                Value<int?> pricePerKgCents = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime?> photoCapturedAt = const Value.absent(),
                Value<String?> substituteItemId = const Value.absent(),
                required int position,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ShoppingItemsTableCompanion.insert(
                id: id,
                listId: listId,
                productType: productType,
                productName: productName,
                brand: brand,
                quantityValue: quantityValue,
                unitPriceCents: unitPriceCents,
                isWholesale: isWholesale,
                isWeightBased: isWeightBased,
                pricePerKgCents: pricePerKgCents,
                weightKg: weightKg,
                photoUrl: photoUrl,
                photoCapturedAt: photoCapturedAt,
                substituteItemId: substituteItemId,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShoppingItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable:
                                    $$ShoppingItemsTableTableReferences
                                        ._listIdTable(db),
                                referencedColumn:
                                    $$ShoppingItemsTableTableReferences
                                        ._listIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShoppingItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingItemsTableTable,
      ShoppingItemsTableData,
      $$ShoppingItemsTableTableFilterComposer,
      $$ShoppingItemsTableTableOrderingComposer,
      $$ShoppingItemsTableTableAnnotationComposer,
      $$ShoppingItemsTableTableCreateCompanionBuilder,
      $$ShoppingItemsTableTableUpdateCompanionBuilder,
      (ShoppingItemsTableData, $$ShoppingItemsTableTableReferences),
      ShoppingItemsTableData,
      PrefetchHooks Function({bool listId})
    >;
typedef $$PurchasesTableTableCreateCompanionBuilder =
    PurchasesTableCompanion Function({
      required String id,
      required String userId,
      required String listId,
      Value<String?> marketName,
      required int totalAmountCents,
      Value<int?> budgetGoalCents,
      Value<bool> exceededBudget,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$PurchasesTableTableUpdateCompanionBuilder =
    PurchasesTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> listId,
      Value<String?> marketName,
      Value<int> totalAmountCents,
      Value<int?> budgetGoalCents,
      Value<bool> exceededBudget,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

final class $$PurchasesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PurchasesTableTable,
          PurchasesTableData
        > {
  $$PurchasesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PurchaseItemsTableTable,
    List<PurchaseItemsTableData>
  >
  _purchaseItemsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.purchaseItemsTable,
        aliasName: $_aliasNameGenerator(
          db.purchasesTable.id,
          db.purchaseItemsTable.purchaseId,
        ),
      );

  $$PurchaseItemsTableTableProcessedTableManager get purchaseItemsTableRefs {
    final manager = $$PurchaseItemsTableTableTableManager(
      $_db,
      $_db.purchaseItemsTable,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchasesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTableTable> {
  $$PurchasesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marketName => $composableBuilder(
    column: $table.marketName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmountCents => $composableBuilder(
    column: $table.totalAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetGoalCents => $composableBuilder(
    column: $table.budgetGoalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exceededBudget => $composableBuilder(
    column: $table.exceededBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> purchaseItemsTableRefs(
    Expression<bool> Function($$PurchaseItemsTableTableFilterComposer f) f,
  ) {
    final $$PurchaseItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseItemsTable,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.purchaseItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTableTable> {
  $$PurchasesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marketName => $composableBuilder(
    column: $table.marketName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmountCents => $composableBuilder(
    column: $table.totalAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetGoalCents => $composableBuilder(
    column: $table.budgetGoalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exceededBudget => $composableBuilder(
    column: $table.exceededBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchasesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTableTable> {
  $$PurchasesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get marketName => $composableBuilder(
    column: $table.marketName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAmountCents => $composableBuilder(
    column: $table.totalAmountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get budgetGoalCents => $composableBuilder(
    column: $table.budgetGoalCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get exceededBudget => $composableBuilder(
    column: $table.exceededBudget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  Expression<T> purchaseItemsTableRefs<T extends Object>(
    Expression<T> Function($$PurchaseItemsTableTableAnnotationComposer a) f,
  ) {
    final $$PurchaseItemsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseItemsTable,
          getReferencedColumn: (t) => t.purchaseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseItemsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PurchasesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTableTable,
          PurchasesTableData,
          $$PurchasesTableTableFilterComposer,
          $$PurchasesTableTableOrderingComposer,
          $$PurchasesTableTableAnnotationComposer,
          $$PurchasesTableTableCreateCompanionBuilder,
          $$PurchasesTableTableUpdateCompanionBuilder,
          (PurchasesTableData, $$PurchasesTableTableReferences),
          PurchasesTableData,
          PrefetchHooks Function({bool purchaseItemsTableRefs})
        > {
  $$PurchasesTableTableTableManager(
    _$AppDatabase db,
    $PurchasesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String?> marketName = const Value.absent(),
                Value<int> totalAmountCents = const Value.absent(),
                Value<int?> budgetGoalCents = const Value.absent(),
                Value<bool> exceededBudget = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesTableCompanion(
                id: id,
                userId: userId,
                listId: listId,
                marketName: marketName,
                totalAmountCents: totalAmountCents,
                budgetGoalCents: budgetGoalCents,
                exceededBudget: exceededBudget,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String listId,
                Value<String?> marketName = const Value.absent(),
                required int totalAmountCents,
                Value<int?> budgetGoalCents = const Value.absent(),
                Value<bool> exceededBudget = const Value.absent(),
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => PurchasesTableCompanion.insert(
                id: id,
                userId: userId,
                listId: listId,
                marketName: marketName,
                totalAmountCents: totalAmountCents,
                budgetGoalCents: budgetGoalCents,
                exceededBudget: exceededBudget,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PurchasesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (purchaseItemsTableRefs) db.purchaseItemsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchaseItemsTableRefs)
                    await $_getPrefetchedData<
                      PurchasesTableData,
                      $PurchasesTableTable,
                      PurchaseItemsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PurchasesTableTableReferences
                          ._purchaseItemsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PurchasesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).purchaseItemsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.purchaseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PurchasesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTableTable,
      PurchasesTableData,
      $$PurchasesTableTableFilterComposer,
      $$PurchasesTableTableOrderingComposer,
      $$PurchasesTableTableAnnotationComposer,
      $$PurchasesTableTableCreateCompanionBuilder,
      $$PurchasesTableTableUpdateCompanionBuilder,
      (PurchasesTableData, $$PurchasesTableTableReferences),
      PurchasesTableData,
      PrefetchHooks Function({bool purchaseItemsTableRefs})
    >;
typedef $$PurchaseItemsTableTableCreateCompanionBuilder =
    PurchaseItemsTableCompanion Function({
      required String id,
      required String purchaseId,
      required String productType,
      required String productName,
      required double quantityValue,
      required int unitPriceCents,
      required int totalPriceCents,
      Value<int> rowid,
    });
typedef $$PurchaseItemsTableTableUpdateCompanionBuilder =
    PurchaseItemsTableCompanion Function({
      Value<String> id,
      Value<String> purchaseId,
      Value<String> productType,
      Value<String> productName,
      Value<double> quantityValue,
      Value<int> unitPriceCents,
      Value<int> totalPriceCents,
      Value<int> rowid,
    });

final class $$PurchaseItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PurchaseItemsTableTable,
          PurchaseItemsTableData
        > {
  $$PurchaseItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchasesTableTable _purchaseIdTable(_$AppDatabase db) =>
      db.purchasesTable.createAlias(
        $_aliasNameGenerator(
          db.purchaseItemsTable.purchaseId,
          db.purchasesTable.id,
        ),
      );

  $$PurchasesTableTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchasesTableTableTableManager(
      $_db,
      $_db.purchasesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PurchaseItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTableTable> {
  $$PurchaseItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityValue => $composableBuilder(
    column: $table.quantityValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPriceCents => $composableBuilder(
    column: $table.totalPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchasesTableTableFilterComposer get purchaseId {
    final $$PurchasesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchasesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableTableFilterComposer(
            $db: $db,
            $table: $db.purchasesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTableTable> {
  $$PurchaseItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityValue => $composableBuilder(
    column: $table.quantityValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPriceCents => $composableBuilder(
    column: $table.totalPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchasesTableTableOrderingComposer get purchaseId {
    final $$PurchasesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchasesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableTableOrderingComposer(
            $db: $db,
            $table: $db.purchasesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTableTable> {
  $$PurchaseItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityValue => $composableBuilder(
    column: $table.quantityValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPriceCents => $composableBuilder(
    column: $table.totalPriceCents,
    builder: (column) => column,
  );

  $$PurchasesTableTableAnnotationComposer get purchaseId {
    final $$PurchasesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchasesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.purchasesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseItemsTableTable,
          PurchaseItemsTableData,
          $$PurchaseItemsTableTableFilterComposer,
          $$PurchaseItemsTableTableOrderingComposer,
          $$PurchaseItemsTableTableAnnotationComposer,
          $$PurchaseItemsTableTableCreateCompanionBuilder,
          $$PurchaseItemsTableTableUpdateCompanionBuilder,
          (PurchaseItemsTableData, $$PurchaseItemsTableTableReferences),
          PurchaseItemsTableData,
          PrefetchHooks Function({bool purchaseId})
        > {
  $$PurchaseItemsTableTableTableManager(
    _$AppDatabase db,
    $PurchaseItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<String> productType = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> quantityValue = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> totalPriceCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseItemsTableCompanion(
                id: id,
                purchaseId: purchaseId,
                productType: productType,
                productName: productName,
                quantityValue: quantityValue,
                unitPriceCents: unitPriceCents,
                totalPriceCents: totalPriceCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseId,
                required String productType,
                required String productName,
                required double quantityValue,
                required int unitPriceCents,
                required int totalPriceCents,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseItemsTableCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                productType: productType,
                productName: productName,
                quantityValue: quantityValue,
                unitPriceCents: unitPriceCents,
                totalPriceCents: totalPriceCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PurchaseItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (purchaseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.purchaseId,
                                referencedTable:
                                    $$PurchaseItemsTableTableReferences
                                        ._purchaseIdTable(db),
                                referencedColumn:
                                    $$PurchaseItemsTableTableReferences
                                        ._purchaseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PurchaseItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseItemsTableTable,
      PurchaseItemsTableData,
      $$PurchaseItemsTableTableFilterComposer,
      $$PurchaseItemsTableTableOrderingComposer,
      $$PurchaseItemsTableTableAnnotationComposer,
      $$PurchaseItemsTableTableCreateCompanionBuilder,
      $$PurchaseItemsTableTableUpdateCompanionBuilder,
      (PurchaseItemsTableData, $$PurchaseItemsTableTableReferences),
      PurchaseItemsTableData,
      PrefetchHooks Function({bool purchaseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShoppingListsTableTableTableManager get shoppingListsTable =>
      $$ShoppingListsTableTableTableManager(_db, _db.shoppingListsTable);
  $$ShoppingItemsTableTableTableManager get shoppingItemsTable =>
      $$ShoppingItemsTableTableTableManager(_db, _db.shoppingItemsTable);
  $$PurchasesTableTableTableManager get purchasesTable =>
      $$PurchasesTableTableTableManager(_db, _db.purchasesTable);
  $$PurchaseItemsTableTableTableManager get purchaseItemsTable =>
      $$PurchaseItemsTableTableTableManager(_db, _db.purchaseItemsTable);
}
