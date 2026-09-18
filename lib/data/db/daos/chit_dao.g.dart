part of 'chit_dao.dart';

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
