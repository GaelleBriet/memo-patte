// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SchemaBootstrapTable extends SchemaBootstrap
    with TableInfo<$SchemaBootstrapTable, SchemaBootstrapData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchemaBootstrapTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_bootstrap';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchemaBootstrapData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchemaBootstrapData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchemaBootstrapData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $SchemaBootstrapTable createAlias(String alias) {
    return $SchemaBootstrapTable(attachedDatabase, alias);
  }
}

class SchemaBootstrapData extends DataClass
    implements Insertable<SchemaBootstrapData> {
  final int id;
  const SchemaBootstrapData({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    return map;
  }

  SchemaBootstrapCompanion toCompanion(bool nullToAbsent) {
    return SchemaBootstrapCompanion(id: Value(id));
  }

  factory SchemaBootstrapData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchemaBootstrapData(id: serializer.fromJson<int>(json['id']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<int>(id)};
  }

  SchemaBootstrapData copyWith({int? id}) =>
      SchemaBootstrapData(id: id ?? this.id);
  SchemaBootstrapData copyWithCompanion(SchemaBootstrapCompanion data) {
    return SchemaBootstrapData(id: data.id.present ? data.id.value : this.id);
  }

  @override
  String toString() {
    return (StringBuffer('SchemaBootstrapData(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchemaBootstrapData && other.id == this.id);
}

class SchemaBootstrapCompanion extends UpdateCompanion<SchemaBootstrapData> {
  final Value<int> id;
  const SchemaBootstrapCompanion({this.id = const Value.absent()});
  SchemaBootstrapCompanion.insert({this.id = const Value.absent()});
  static Insertable<SchemaBootstrapData> custom({Expression<int>? id}) {
    return RawValuesInsertable({if (id != null) 'id': id});
  }

  SchemaBootstrapCompanion copyWith({Value<int>? id}) {
    return SchemaBootstrapCompanion(id: id ?? this.id);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchemaBootstrapCompanion(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchemaBootstrapTable schemaBootstrap = $SchemaBootstrapTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [schemaBootstrap];
}

typedef $$SchemaBootstrapTableCreateCompanionBuilder =
    SchemaBootstrapCompanion Function({Value<int> id});
typedef $$SchemaBootstrapTableUpdateCompanionBuilder =
    SchemaBootstrapCompanion Function({Value<int> id});

class $$SchemaBootstrapTableFilterComposer
    extends Composer<_$AppDatabase, $SchemaBootstrapTable> {
  $$SchemaBootstrapTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchemaBootstrapTableOrderingComposer
    extends Composer<_$AppDatabase, $SchemaBootstrapTable> {
  $$SchemaBootstrapTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchemaBootstrapTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchemaBootstrapTable> {
  $$SchemaBootstrapTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$SchemaBootstrapTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchemaBootstrapTable,
          SchemaBootstrapData,
          $$SchemaBootstrapTableFilterComposer,
          $$SchemaBootstrapTableOrderingComposer,
          $$SchemaBootstrapTableAnnotationComposer,
          $$SchemaBootstrapTableCreateCompanionBuilder,
          $$SchemaBootstrapTableUpdateCompanionBuilder,
          (
            SchemaBootstrapData,
            BaseReferences<
              _$AppDatabase,
              $SchemaBootstrapTable,
              SchemaBootstrapData
            >,
          ),
          SchemaBootstrapData,
          PrefetchHooks Function()
        > {
  $$SchemaBootstrapTableTableManager(
    _$AppDatabase db,
    $SchemaBootstrapTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchemaBootstrapTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchemaBootstrapTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchemaBootstrapTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({Value<int> id = const Value.absent()}) =>
              SchemaBootstrapCompanion(id: id),
          createCompanionCallback: ({Value<int> id = const Value.absent()}) =>
              SchemaBootstrapCompanion.insert(id: id),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchemaBootstrapTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchemaBootstrapTable,
      SchemaBootstrapData,
      $$SchemaBootstrapTableFilterComposer,
      $$SchemaBootstrapTableOrderingComposer,
      $$SchemaBootstrapTableAnnotationComposer,
      $$SchemaBootstrapTableCreateCompanionBuilder,
      $$SchemaBootstrapTableUpdateCompanionBuilder,
      (
        SchemaBootstrapData,
        BaseReferences<
          _$AppDatabase,
          $SchemaBootstrapTable,
          SchemaBootstrapData
        >,
      ),
      SchemaBootstrapData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchemaBootstrapTableTableManager get schemaBootstrap =>
      $$SchemaBootstrapTableTableManager(_db, _db.schemaBootstrap);
}
