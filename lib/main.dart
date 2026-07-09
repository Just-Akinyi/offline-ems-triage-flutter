import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/triage_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final repo = TriageRepository();
  await repo.init();

  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: Center(child: Text('Storage Ready'))),
      ),
    ),
  );
}