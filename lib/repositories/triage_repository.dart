import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/triage_model.dart';

class TriageRepository {
  static const String _boxName = 'triage_cache';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);
  
  Future<void> saveLocally(TriageModel record) async {
    await _box.put(record.id, record.toMap());
  }

  
  List<TriageModel> getCachedRecords() {
    return _box.values.map((e) => TriageModel.fromMap(e as Map)).toList();
  }

  
  Future<void> clearFromCache(String id) async {
    await _box.delete(id);
  }

  Future<bool> mockApiUpload(TriageModel record, bool isOnline) async {
    await Future.delayed(const Duration(seconds: 2)); 
    if (!isOnline) {
      return false;
    }
    return true;
  }
}