import 'package:dairycare_mobile/app/environment.dart';
import 'package:dairycare_mobile/core/api/api_client.dart';
import 'package:dairycare_mobile/features/health/data/health_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'health repository loads symptoms, saves assessment, and reloads history',
    () async {
      final requests = <RequestOptions>[];
      final repository = HealthRepository(api: _api(requests));
      final symptoms = await repository.symptoms();
      final saved = await repository.assess('animal-1', {
        'severity': 'severe',
        'symptom_ids': ['symptom-1'],
      });
      final cases = await repository.cases('animal-1');
      final guidance = await repository.askHealthGuide({
        'question': 'Mouth blisters and too much saliva',
        'species': 'cattle',
        'symptom_codes': ['mouth_blisters'],
        'language': 'both',
      });
      final evaluations = await repository.evaluationCases();
      final reviewed = await repository.reviewEvaluationCase('eval-1', {
        'decision': 'approved',
        'reviewer_name': 'Dr Ayesha',
        'reviewer_registration': 'PVMC-1',
        'reviewer_notes': 'Reviewed clinically.',
      });
      final history = await repository.evaluationReviewHistory('eval-1');
      final medicines = await repository.medicineEvidence();
      expect(symptoms.single.isEmergency, isTrue);
      expect(saved.emergency, isTrue);
      expect(saved.differentials.single.name, 'Foot-and-mouth disease');
      expect(cases.single.caseNumber, 'HC-000001');
      expect(guidance.emergency, isTrue);
      expect(guidance.matches.single.code, 'fmd');
      expect(guidance.matches.single.source.title, 'WOAH');
      expect(evaluations.single.code, 'EVAL-FMD-01');
      expect(reviewed.reviewVersion, 2);
      expect(history.single.reviewerRegistration, 'PVMC-1');
      expect(medicines.single.drapRegistrationNumber, 'DRAP-VET-1');
      expect(
        requests.map((r) => '${r.method} ${r.path}'),
        containsAll([
          'GET /health/symptoms',
          'POST /animals/animal-1/health-assessments',
          'GET /animals/animal-1/health-cases',
          'POST /health/ai/ask',
          'GET /health/ai/evaluation-cases',
          'POST /health/ai/evaluation-cases/eval-1/review',
          'GET /health/ai/evaluation-cases/eval-1/reviews',
          'GET /health/medicine-evidence',
        ]),
      );
      expect(
        requests
            .firstWhere((r) => r.method == 'POST')
            .headers['Idempotency-Key'],
        isNotNull,
      );
    },
  );
}

ApiClient _api(List<RequestOptions> requests) {
  final dio = Dio();
  final api = ApiClient(
    config: EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: Uri.parse('http://example.test/api/v1'),
    ),
    readAccessToken: () async => 'token',
    dio: dio,
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        final data = options.path == '/health/symptoms'
            ? [_symptom()]
            : options.path == '/health/medicine-evidence'
            ? [_medicineEvidence()]
            : options.path == '/health/ai/evaluation-cases'
            ? [_evaluation()]
            : options.path.endsWith('/reviews')
            ? [_evaluationReview()]
            : options.path.contains('/health/ai/evaluation-cases/')
            ? {..._evaluation(), 'review_version': 2}
            : options.path == '/health/ai/ask'
            ? _guidance()
            : options.method == 'GET'
            ? [_case()]
            : _case();
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: {'data': data},
          ),
        );
      },
    ),
  );
  return api;
}

Map<String, dynamic> _guidance() => {
  'mode': 'deterministic',
  'answer': 'Possible foot-and-mouth disease. Isolate the animal.',
  'answer_roman_urdu': 'Janwar ko alag karein aur foran vet ko bulayein.',
  'emergency': true,
  'safety_notice': 'This is not a diagnosis or prescription.',
  'matches': [
    {
      'code': 'fmd',
      'name': 'Foot-and-mouth disease',
      'name_roman_urdu': 'Munh aur khur ki bimari',
      'urgency': 'emergency',
      'summary': 'Possible contagious vesicular disease.',
      'immediate_care': 'Isolate and call a veterinarian.',
      'immediate_care_roman_urdu': 'Alag karein aur vet ko bulayein.',
      'do_not_do': 'Do not move the animal.',
      'feed_water_guidance': 'Keep clean water accessible.',
      'confirmation_guidance': 'Veterinary examination and laboratory test.',
      'source': {
        'title': 'WOAH',
        'url': 'https://www.woah.org/',
        'reviewed_on': '2026-08-12',
      },
    },
  ],
};

Map<String, dynamic> _evaluation() => {
  'id': 'eval-1',
  'case_code': 'EVAL-FMD-01',
  'species': 'cattle',
  'question_en': 'Mouth blisters and saliva',
  'question_roman_urdu': 'Munh mein chalay aur ral',
  'symptom_codes': ['mouth_blisters'],
  'expected_disease_codes': ['fmd'],
  'expected_emergency': true,
  'expects_match': true,
  'review_status': 'approved',
  'review_version': 1,
};

Map<String, dynamic> _evaluationReview() => {
  'id': 'review-1',
  'decision': 'approved',
  'reviewer_notes': 'Reviewed clinically.',
  'reviewer_name': 'Dr Ayesha',
  'reviewer_registration': 'PVMC-1',
  'reviewed_at': '2026-08-12T10:00:00Z',
};
Map<String, dynamic> _medicineEvidence() => {
  'id': 'med-1',
  'disease_id': 'disease-1',
  'disease_name': 'Mastitis',
  'active_ingredient': 'Verified ingredient',
  'brand_name': 'Verified brand',
  'manufacturer': 'Manufacturer',
  'dosage_form': 'Veterinary formulation',
  'drap_registration_number': 'DRAP-VET-1',
  'drap_registry_url': 'https://eapp.dra.gov.pk/WebProductIndex.php',
  'indication': 'Veterinary evidence',
  'species_scope': 'Cattle',
  'contraindications': 'Vet assessment required',
  'withdrawal_guidance': 'Use current label',
  'review_status': 'approved',
  'review_version': 2,
  'prescribing_notice': 'Veterinarian must prescribe.',
};

Map<String, dynamic> _symptom() => {
  'id': 'symptom-1',
  'code': 'mouth_blisters',
  'name': 'Mouth blisters',
  'body_system': 'oral',
  'is_emergency': true,
  'emergency_message': 'Urgent',
};
Map<String, dynamic> _case() => {
  'id': 'case-1',
  'case_number': 'HC-000001',
  'reported_at': '2026-08-12T08:00:00Z',
  'severity': 'severe',
  'status': 'open',
  'emergency': true,
  'emergency_message': 'Urgent',
  'symptoms': [_symptom()],
  'differentials': [
    {
      'rank': 1,
      'score': '90.00',
      'matched_symptoms': ['Mouth blisters'],
      'missing_key_symptoms': [],
      'disease': {
        'code': 'fmd',
        'name': 'Foot-and-mouth disease',
        'summary': 'Possible vesicular disease',
        'urgency': 'emergency',
        'immediate_care': 'Isolate',
        'confirmation_guidance': 'Veterinarian and lab',
        'source_title': 'WOAH',
        'source_url': 'https://www.woah.org/',
      },
    },
  ],
};
