// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_dao.dart';

// ignore_for_file: type=lint
mixin _$VaccinationDaoMixin on DatabaseAccessor<AppDatabase> {
  $AnimalsTable get animals => attachedDatabase.animals;
  $VaccinationsTable get vaccinations => attachedDatabase.vaccinations;
  VaccinationDaoManager get managers => VaccinationDaoManager(this);
}

class VaccinationDaoManager {
  final _$VaccinationDaoMixin _db;
  VaccinationDaoManager(this._db);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db.attachedDatabase, _db.animals);
  $$VaccinationsTableTableManager get vaccinations =>
      $$VaccinationsTableTableManager(_db.attachedDatabase, _db.vaccinations);
}
