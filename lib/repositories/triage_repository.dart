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

  // Cache record locally immediately
  Future<void> saveLocally(TriageModel record) async {
    await _box.put(record.id, record.toMap());
  }

  // Get all pending cached files
  List<TriageModel> getCachedRecords() {
    return _box.values.map((e) => TriageModel.fromMap(e as Map)).toList();
  }

  // Remove from cache after successful upload
  Future<void> clearFromCache(String id) async {
    await _box.delete(id);
  }

  // Simulates POST /api/v1/triage with network evaluation
  Future<bool> mockApiUpload(TriageModel record, bool isOnline) async {
    await Future.delayed(const Duration(seconds: 2)); // Artificial 2s latency
    if (!isOnline) {
      return false; // Network fail simulation
    }
    return true; // Successfully uploaded
  }
}