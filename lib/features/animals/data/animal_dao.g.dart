// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_dao.dart';

// ignore_for_file: type=lint
mixin _$AnimalDaoMixin on DatabaseAccessor<AppDatabase> {
  $AnimalsTable get animals => attachedDatabase.animals;
  AnimalDaoManager get managers => AnimalDaoManager(this);
}

class AnimalDaoManager {
  final _$AnimalDaoMixin _db;
  AnimalDaoManager(this._db);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db.attachedDatabase, _db.animals);
}
