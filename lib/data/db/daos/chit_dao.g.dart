// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chit_dao.dart';

// ignore_for_file: type=lint
mixin _$ChitDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChitsTable get chits => attachedDatabase.chits;
  ChitDaoManager get managers => ChitDaoManager(this);
}

class ChitDaoManager {
  final _$ChitDaoMixin _db;
  ChitDaoManager(this._db);
  $$ChitsTableTableManager get chits =>
      $$ChitsTableTableManager(_db.attachedDatabase, _db.chits);
}
