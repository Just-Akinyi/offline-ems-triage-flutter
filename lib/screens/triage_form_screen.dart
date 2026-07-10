import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/triage_model.dart';
import '../providers/triage_provider.dart';

class TriageFormScreen extends ConsumerStatefulWidget {
  const TriageFormScreen({super.key});

  @override
  ConsumerState<TriageFormScreen> createState() => _TriageFormScreenState();
}

class _TriageFormScreenState extends ConsumerState<TriageFormScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _priorityLevel = 3;
  String _status = 'Pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
     
      ref.read(triageProvider.notifier).initConnectivity(); 
    }
  }

  Color _getHazardColor(int priority) {
    if (priority == 1) return const Color(0xFFD32F2F);
    if (priority == 2) return const Color(0xFFE65100);
    return Colors.grey.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final triageState = ref.watch(triageProvider);

    ref.listen<TriageState>(triageProvider, (prev, next) {
      if (next.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message!), duration: const Duration(seconds: 3)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMS Triage Intake', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Chip(
              backgroundColor: triageState.isOnline ? Colors.green.shade700 : Colors.red.shade700,
              label: Text(
                triageState.isOnline ? 'ONLINE' : 'OFFLINE',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             
              if (triageState.cachedCount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.amber.shade800,
                  child: Text(
                    'Queue alert: ${triageState.cachedCount} forms waiting sync.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Patient Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Condition Description', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 16),
              
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: _getHazardColor(_priorityLevel), width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<int>(
                  value: _priorityLevel,
                  decoration: const InputDecoration(labelText: 'Priority Level (1-CRITICAL to 5-LOW)', border: InputBorder.none),
                  items: [1, 2, 3, 4, 5].map((level) {
                    return DropdownMenuItem(value: level, child: Text('Priority $level'));
                  }).toList(),
                  onChanged: (val) => setState(() => _priorityLevel = val ?? 3),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Pending', 'In-Transit'].map((st) {
                  return DropdownMenuItem(value: st, child: Text(st));
                }).toList(),
                onChanged: (val) => setState(() => _status = val ?? 'Pending'),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _getHazardColor(_priorityLevel),
                  foregroundColor: Colors.white,
                ),
                onPressed: triageState.isSubmitting ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    final record = TriageModel(
                      id: const Uuid().v4(),
                      patientName: _nameController.text.trim(),
                      conditionDescription: _descController.text.trim(),
                      priorityLevel: _priorityLevel,
                      status: _status,
                    );
                    await ref.read(triageProvider.notifier).submitTriage(record);
                    _nameController.clear();
                    _descController.clear();
                  }
                },
                child: triageState.isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('SUBMIT INTAKE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}