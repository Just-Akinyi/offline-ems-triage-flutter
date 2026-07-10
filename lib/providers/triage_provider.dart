import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/triage_model.dart';
import '../repositories/triage_repository.dart';

final triageRepositoryProvider = Provider((ref) => TriageRepository());

final triageProvider = StateNotifierProvider<TriageNotifier, TriageState>((ref) {
  return TriageNotifier(ref.read(triageRepositoryProvider));
});

class TriageState {
  final bool isSubmitting;
  final bool isOnline;
  final int cachedCount;
  final String? message;

  TriageState({
    this.isSubmitting = false,
    this.isOnline = true,
    this.cachedCount = 0,
    this.message,
  });

  TriageState copyWith({bool? isSubmitting, bool? isOnline, int? cachedCount, String? message}) {
    return TriageState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isOnline: isOnline ?? this.isOnline,
      cachedCount: cachedCount ?? this.cachedCount,
      message: message,
    );
  }
}

class TriageNotifier extends StateNotifier<TriageState> {
  final TriageRepository _repo;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  TriageNotifier(this._repo) : super(TriageState()) {
    // Call the newly named public method
    initConnectivity();
  }

  // Changed from private _initConnectivity() to public initConnectivity()
  void initConnectivity() {
    // Initial check
    Connectivity().checkConnectivity().then(_updateConnectionStatus);
    // Listen for changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool online = !results.contains(ConnectivityResult.none);
    state = state.copyWith(isOnline: online, cachedCount: _repo.getCachedRecords().length);
    if (online) {
      _processSyncQueue();
    }
  }

  Future<void> submitTriage(TriageModel record) async {
    state = state.copyWith(isSubmitting: true);
   
    await _repo.saveLocally(record);
    state = state.copyWith(cachedCount: _repo.getCachedRecords().length);

    bool success = await _repo.mockApiUpload(record, state.isOnline);
    if (success) {
      await _repo.clearFromCache(record.id);
      state = state.copyWith(
        isSubmitting: false, 
        cachedCount: _repo.getCachedRecords().length,
        message: "Successfully uploaded to server live!",
      );
    } else {
      state = state.copyWith(
        isSubmitting: false,
        message: "Offline or link down! Safely cached locally on device.",
      );
    }
  }

  // Background Sync Engine loop
  Future<void> _processSyncQueue() async {
    final records = _repo.getCachedRecords();
    if (records.isEmpty) return;

    for (var record in records) {
      if (!state.isOnline) break;
      bool success = await _repo.mockApiUpload(record, true);
      if (success) {
        await _repo.clearFromCache(record.id);
        state = state.copyWith(cachedCount: _repo.getCachedRecords().length);
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}