import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';      // Mobile
import 'package:sembast_web/sembast_web.dart'; // Web

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._internal();
  factory DatabaseService() => _singleton;
  DatabaseService._internal();

  late Database _db;
  final _store = intMapStoreFactory.store('maquinas');

  Future<void> init() async {
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('inventario.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final dbPath = join(dir.path, 'inventario.db');
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }
  }

  Future<int> insert(Map<String, dynamic> data) async {
    return await _store.add(_db, data);
  }

  Future<List<RecordSnapshot<int, Map<String, dynamic>>>> getAll() async {
    return await _store.find(_db);
  }

  Future<void> update(int key, Map<String, dynamic> data) async {
    await _store.record(key).put(_db, data);
  }

  Future<void> delete(int key) async {
    await _store.record(key).delete(_db);
  }

  Future<List<Map<String, dynamic>>> searchByField(String field, dynamic value) async {
    final finder = Finder(filter: Filter.equals(field, value));
    final records = await _store.find(_db, finder: finder);
    return records.map((e) => e.value).toList();
  }

  Future<void> _init() async {
    if (_db != null) return;

    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('machines.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = join(dir.path, 'machines.db');
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }
  }

  /// Adiciona uma máquina ao banco
  Future<void> addMachine(Map<String, dynamic> data) async {
    await _init();
    await _store.add(_db!, data);
  }

  /// Retorna todas as máquinas cadastradas
  Future<List<Map<String, dynamic>>> getAllMachines() async {
    await _init();
    final snapshots = await _store.find(_db!);
    return snapshots.map((s) => s.value).toList();
  }
}
