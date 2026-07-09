import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/triage_provider.dart';
import 'repositories/triage_repository.dart';
import 'screens/triage_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final repo = TriageRepository();
  await repo.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMS Triage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const TriageFormScreen(),
    );
  }
}