import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_ems_triage_flutter/models/triage_model.dart';
import 'package:offline_ems_triage_flutter/providers/triage_provider.dart';
import 'package:offline_ems_triage_flutter/repositories/triage_repository.dart';

class MockTriageRepository extends Mock implements TriageRepository {}

class FakeTriageModel extends Fake implements TriageModel {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeTriageModel());
  });

  late MockTriageRepository mockRepo;
  late TriageModel sampleRecord;

  void mockNetworkState(String state) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return [state];
        }
        return null;
      },
    );
  }

  setUp(() {
    mockRepo = MockTriageRepository();
    sampleRecord = TriageModel(
      id: '123',
      patientName: 'John Doe',
      conditionDescription: 'Critical',
      priorityLevel: 1,
      status: 'Pending',
    );
  });

  group('TriageNotifier Sync Engine Tests', () {
    test('Should upload instantly and clear cache when ONLINE', () async {
      mockNetworkState('wifi');

      when(() => mockRepo.getCachedRecords()).thenReturn([]);
      when(() => mockRepo.saveLocally(any())).thenAnswer((_) async => {});
      when(() => mockRepo.mockApiUpload(any(), true)).thenAnswer((_) async => true);
      when(() => mockRepo.clearFromCache(any())).thenAnswer((_) async => {});

      final notifier = TriageNotifier(mockRepo);
      await notifier.submitTriage(sampleRecord);

      verify(() => mockRepo.saveLocally(sampleRecord)).called(1);
      verify(() => mockRepo.mockApiUpload(sampleRecord, true)).called(1);
      verify(() => mockRepo.clearFromCache(sampleRecord.id)).called(1);
    });

    test('Should preserve cache when submission fails due to being OFFLINE', () async {
      mockNetworkState('none');

      when(() => mockRepo.getCachedRecords()).thenReturn([sampleRecord]);
      when(() => mockRepo.saveLocally(any())).thenAnswer((_) async => {});
      when(() => mockRepo.mockApiUpload(any(), false)).thenAnswer((_) async => false);

      final notifier = TriageNotifier(mockRepo);
      notifier.state = notifier.state.copyWith(isOnline: false); 

      await notifier.submitTriage(sampleRecord);

      expect(notifier.state.cachedCount, 1);
      verifyNever(() => mockRepo.clearFromCache(any()));
    });
  });
}