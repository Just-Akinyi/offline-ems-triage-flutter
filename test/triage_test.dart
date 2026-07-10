import 'package:flutter_test/flutter_test.dart';
import '../lib/models/triage_model.dart';

void main() {
  group('TriageModel Validation Tests', () {
    test('Should correctly initialize triage model properties', () {
      final model = TriageModel(
        id: '123',
        patientName: 'John Doe',
        conditionDescription: 'Cardiac Arrest',
        priorityLevel: 1,
        status: 'Pending',
      );

      expect(model.patientName, 'John Doe');
      expect(model.priorityLevel, 1);
    });

    test('Should convert map data accurately into model properties', () {
      final map = {
        'id': 'abc',
        'patientName': 'Jane Doe',
        'conditionDescription': 'Fracture',
        'priorityLevel': 4,
        'status': 'In-Transit',
      };
      
      final model = TriageModel.fromMap(map);
      expect(model.conditionDescription, 'Fracture');
    });
  });
}
