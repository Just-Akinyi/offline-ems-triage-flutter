class TriageModel {
  final String id;
  final String patientName;
  final String conditionDescription;
  final int priorityLevel;
  final String status;

  TriageModel({
    required this.id,
    required this.patientName,
    required this.conditionDescription,
    required this.priorityLevel,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'conditionDescription': conditionDescription,
      'priorityLevel': priorityLevel,
      'status': status,
    };
  }

  factory TriageModel.fromMap(Map<dynamic, dynamic> map) {
    return TriageModel(
      id: map['id'] as String,
      patientName: map['patientName'] as String,
      conditionDescription: map['conditionDescription'] as String,
      priorityLevel: map['priorityLevel'] as int,
      status: map['status'] as String,
    );
  }
}
