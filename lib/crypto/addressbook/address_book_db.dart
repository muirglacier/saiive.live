import 'dart:io';

import 'package:saiive.live/crypto/model/address_book_model.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';

abstract class IAddressBookDatabase {
  Future<List<AddressBookEntry>> getAddressBook();
  Future addAddressBookEntry(AddressBookEntry entry);
  Future removeAddressBookEntry(AddressBookEntry entry);
  Future updateAddressBookEntry(AddressBookEntry entry);

  Future open();
  Future close();
  Future destroy();
}

class AddressBookDatabase extends IAddressBookDatabase {
  Database _database;

  static const String _addressBookStore = "addressBookEntryV1";
  final StoreRef _addressBookStoreInstance = stringMapStoreFactory.store(_addressBookStore);

  final String _path;
  AddressBookDatabase(this._path);

  Future<Database> get database async {
    if (_database != null) return _database;

    final instanceId = await SharedPrefsUtil().getInstanceId();
    final path = join(_path, "addressbook_$instanceId.db");

    _database = await databaseFactoryIo.openDatabase(path);
    return _database;
  }

  @override
  Future close() async {
    _database.close();
    _database = null;
  }

  @override
  Future destroy() async {
    var db = await database;
    await _addressBookStoreInstance.delete(db);

    await close();
    _database = null;

    final instanceId = await SharedPrefsUtil().getInstanceId();
    final path = join(_path, "addressbook_$instanceId.db");

    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future open() async {}

  @override
  Future addAddressBookEntry(AddressBookEntry entry) async {
    final db = await database;
    await _addressBookStoreInstance.record(entry.id).put(db, entry.toJson());
  }

  @override
  Future<List<AddressBookEntry>> getAddressBook() async {
    var dbStore = _addressBookStoreInstance;

    var db = await database;

    final accounts = await dbStore.find(db);

    final data = accounts.map((e) => e == null ? null : AddressBookEntry.fromJson(e.value))?.toList();

    return data;
  }

  @override
  Future removeAddressBookEntry(AddressBookEntry entry) async {
    final db = await database;
    await _addressBookStoreInstance.record(entry.id).delete(db);
  }

  @override
  Future updateAddressBookEntry(AddressBookEntry entry) async {
    final db = await database;
    await _addressBookStoreInstance.record(entry.id).put(db, entry.toJson());
  }
}
