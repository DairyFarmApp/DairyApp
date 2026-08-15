final class HealthSymptom {
  const HealthSymptom({
    required this.id,
    required this.code,
    required this.name,
    this.nameRomanUrdu,
    required this.bodySystem,
    required this.isEmergency,
    this.emergencyMessage,
  });
  factory HealthSymptom.fromJson(Map<String, dynamic> json) => HealthSymptom(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    nameRomanUrdu: json['name_roman_urdu'] as String?,
    bodySystem: json['body_system'] as String,
    isEmergency: json['is_emergency'] as bool? ?? false,
    emergencyMessage: json['emergency_message'] as String?,
  );
  final String id, code, name, bodySystem;
  final String? nameRomanUrdu;
  final bool isEmergency;
  final String? emergencyMessage;
}

final class HealthAiSource {
  const HealthAiSource({
    required this.title,
    required this.url,
    this.reviewedOn,
  });

  factory HealthAiSource.fromJson(Map<String, dynamic> json) => HealthAiSource(
    title: json['title'] as String? ?? 'Approved veterinary source',
    url: json['url'] as String? ?? '',
    reviewedOn: json['reviewed_on'] as String?,
  );

  final String title, url;
  final String? reviewedOn;
}

final class HealthAiMatch {
  const HealthAiMatch({
    required this.code,
    required this.name,
    required this.urgency,
    required this.summary,
    required this.immediateCare,
    required this.source,
    this.nameRomanUrdu,
    this.immediateCareRomanUrdu,
    this.doNotDo,
    this.feedWaterGuidance,
    this.confirmationGuidance,
  });

  factory HealthAiMatch.fromJson(Map<String, dynamic> json) => HealthAiMatch(
    code: json['code'] as String,
    name: json['name'] as String,
    nameRomanUrdu: json['name_roman_urdu'] as String?,
    urgency: json['urgency'] as String? ?? 'routine',
    summary: json['summary'] as String? ?? '',
    immediateCare: json['immediate_care'] as String? ?? '',
    immediateCareRomanUrdu: json['immediate_care_roman_urdu'] as String?,
    doNotDo: json['do_not_do'] as String?,
    feedWaterGuidance: json['feed_water_guidance'] as String?,
    confirmationGuidance: json['confirmation_guidance'] as String?,
    source: HealthAiSource.fromJson(
      (json['source'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
  );

  final String code, name, urgency, summary, immediateCare;
  final String? nameRomanUrdu,
      immediateCareRomanUrdu,
      doNotDo,
      feedWaterGuidance,
      confirmationGuidance;
  final HealthAiSource source;
}

final class HealthAiAnswer {
  const HealthAiAnswer({
    required this.mode,
    required this.answer,
    required this.answerRomanUrdu,
    required this.emergency,
    required this.safetyNotice,
    required this.matches,
  });

  factory HealthAiAnswer.fromJson(Map<String, dynamic> json) => HealthAiAnswer(
    mode: json['mode'] as String? ?? 'deterministic',
    answer: json['answer'] as String? ?? '',
    answerRomanUrdu: json['answer_roman_urdu'] as String? ?? '',
    emergency: json['emergency'] as bool? ?? false,
    safetyNotice: json['safety_notice'] as String? ?? '',
    matches: (json['matches'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              HealthAiMatch.fromJson((item as Map).cast<String, dynamic>()),
        )
        .toList(),
  );

  final String mode, answer, answerRomanUrdu, safetyNotice;
  final bool emergency;
  final List<HealthAiMatch> matches;
}

final class HealthAiEvaluationCase {
  const HealthAiEvaluationCase({
    required this.id,
    required this.code,
    required this.species,
    required this.questionEn,
    required this.questionRomanUrdu,
    required this.symptomCodes,
    required this.expectedDiseaseCodes,
    required this.expectedEmergency,
    required this.expectsMatch,
    required this.reviewStatus,
    required this.reviewVersion,
    this.reviewNotes,
    this.reviewerName,
    this.reviewerRegistration,
    this.reviewedAt,
  });
  factory HealthAiEvaluationCase.fromJson(Map<String, dynamic> json) =>
      HealthAiEvaluationCase(
        id: json['id'] as String,
        code: json['case_code'] as String,
        species: json['species'] as String,
        questionEn: json['question_en'] as String? ?? '',
        questionRomanUrdu: json['question_roman_urdu'] as String? ?? '',
        symptomCodes: (json['symptom_codes'] as List<dynamic>? ?? const [])
            .cast<String>(),
        expectedDiseaseCodes:
            (json['expected_disease_codes'] as List<dynamic>? ?? const [])
                .cast<String>(),
        expectedEmergency: json['expected_emergency'] as bool? ?? false,
        expectsMatch: json['expects_match'] as bool? ?? true,
        reviewStatus: json['review_status'] as String? ?? 'pending_review',
        reviewVersion: (json['review_version'] as num?)?.toInt() ?? 1,
        reviewNotes: json['review_notes'] as String?,
        reviewerName: json['reviewer_name'] as String?,
        reviewerRegistration: json['reviewer_registration'] as String?,
        reviewedAt: json['reviewed_at'] == null
            ? null
            : DateTime.tryParse(json['reviewed_at'] as String),
      );
  final String id, code, species, questionEn, questionRomanUrdu, reviewStatus;
  final List<String> symptomCodes, expectedDiseaseCodes;
  final bool expectedEmergency, expectsMatch;
  final int reviewVersion;
  final String? reviewNotes, reviewerName, reviewerRegistration;
  final DateTime? reviewedAt;
}

final class HealthAiEvaluationReview {
  const HealthAiEvaluationReview({
    required this.id,
    required this.decision,
    required this.notes,
    required this.reviewerName,
    required this.reviewerRegistration,
    required this.reviewedAt,
  });
  factory HealthAiEvaluationReview.fromJson(Map<String, dynamic> json) =>
      HealthAiEvaluationReview(
        id: json['id'] as String,
        decision: json['decision'] as String,
        notes: json['reviewer_notes'] as String,
        reviewerName: json['reviewer_name'] as String,
        reviewerRegistration: json['reviewer_registration'] as String,
        reviewedAt: DateTime.parse(json['reviewed_at'] as String),
      );
  final String id, decision, notes, reviewerName, reviewerRegistration;
  final DateTime reviewedAt;
}

final class HealthMedicineEvidence {
  const HealthMedicineEvidence({
    required this.id,
    required this.diseaseId,
    required this.diseaseName,
    required this.activeIngredient,
    required this.brandName,
    required this.manufacturer,
    required this.dosageForm,
    required this.drapRegistrationNumber,
    required this.drapRegistryUrl,
    required this.indication,
    required this.speciesScope,
    required this.contraindications,
    required this.withdrawalGuidance,
    required this.reviewStatus,
    required this.reviewVersion,
    required this.prescribingNotice,
  });
  factory HealthMedicineEvidence.fromJson(Map<String, dynamic> j) =>
      HealthMedicineEvidence(
        id: j['id'] as String,
        diseaseId: j['disease_id'] as String,
        diseaseName: j['disease_name'] as String,
        activeIngredient: j['active_ingredient'] as String,
        brandName: j['brand_name'] as String,
        manufacturer: j['manufacturer'] as String,
        dosageForm: j['dosage_form'] as String,
        drapRegistrationNumber: j['drap_registration_number'] as String,
        drapRegistryUrl: j['drap_registry_url'] as String,
        indication: j['indication'] as String,
        speciesScope: j['species_scope'] as String,
        contraindications: j['contraindications'] as String,
        withdrawalGuidance: j['withdrawal_guidance'] as String,
        reviewStatus: j['review_status'] as String,
        reviewVersion: (j['review_version'] as num).toInt(),
        prescribingNotice: j['prescribing_notice'] as String,
      );
  final String id,
      diseaseId,
      diseaseName,
      activeIngredient,
      brandName,
      manufacturer,
      dosageForm,
      drapRegistrationNumber,
      drapRegistryUrl,
      indication,
      speciesScope,
      contraindications,
      withdrawalGuidance,
      reviewStatus,
      prescribingNotice;
  final int reviewVersion;
}

final class PreventiveCareRecord {
  const PreventiveCareRecord({
    required this.id,
    required this.number,
    required this.type,
    required this.dose,
    required this.doseUnit,
    required this.administeredAt,
    required this.dueStatus,
    required this.costPkr,
    this.nextDueDate,
    this.diseaseCovered,
    this.veterinarianName,
    this.reaction,
  });
  factory PreventiveCareRecord.fromJson(Map<String, dynamic> json) =>
      PreventiveCareRecord(
        id: json['id'] as String,
        number: json['record_number'] as String,
        type: json['type'] as String,
        dose: json['dose'].toString(),
        doseUnit: json['dose_unit'] as String,
        administeredAt: DateTime.parse(json['administered_at'] as String),
        nextDueDate: json['next_due_date'] == null
            ? null
            : DateTime.parse(json['next_due_date'] as String),
        dueStatus: json['due_status'] as String,
        costPkr: json['cost_pkr'].toString(),
        diseaseCovered: json['disease_covered'] as String?,
        veterinarianName: json['veterinarian_name'] as String?,
        reaction: json['reaction'] as String?,
      );
  final String id, number, type, dose, doseUnit, dueStatus, costPkr;
  final DateTime administeredAt;
  final DateTime? nextDueDate;
  final String? diseaseCovered, veterinarianName, reaction;
}

final class HealthKnowledgeEntry {
  const HealthKnowledgeEntry({
    required this.id,
    required this.name,
    required this.species,
    required this.summary,
    required this.immediateCare,
    required this.confirmationGuidance,
    required this.urgency,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.reviewStatus,
    required this.version,
    required this.symptoms,
    this.nameRomanUrdu,
    this.summaryRomanUrdu,
    this.immediateCareRomanUrdu,
    this.confirmationRomanUrdu,
    this.safeHomeCare,
    this.safeHomeCareRomanUrdu,
  });
  factory HealthKnowledgeEntry.fromJson(Map<String, dynamic> json) =>
      HealthKnowledgeEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        nameRomanUrdu: json['name_roman_urdu'] as String?,
        species: (json['species'] as List).cast<String>(),
        summary: json['summary'] as String,
        summaryRomanUrdu: json['summary_roman_urdu'] as String?,
        immediateCare: json['immediate_care'] as String,
        immediateCareRomanUrdu: json['immediate_care_roman_urdu'] as String?,
        confirmationGuidance: json['confirmation_guidance'] as String,
        confirmationRomanUrdu:
            json['confirmation_guidance_roman_urdu'] as String?,
        safeHomeCare: json['safe_home_care'] as String?,
        safeHomeCareRomanUrdu: json['safe_home_care_roman_urdu'] as String?,
        urgency: json['urgency'] as String,
        sourceTitle: json['source_title'] as String,
        sourceUrl: json['source_url'] as String,
        reviewStatus: json['review_status'] as String,
        version: (json['knowledge_version'] as num).toInt(),
        symptoms: (json['symptoms'] as List)
            .cast<Map<String, dynamic>>()
            .map((s) => '${s['name']} / ${s['name_roman_urdu'] ?? ''}')
            .toList(),
      );
  final String id,
      name,
      summary,
      immediateCare,
      confirmationGuidance,
      urgency,
      sourceTitle,
      sourceUrl,
      reviewStatus;
  final String? nameRomanUrdu,
      summaryRomanUrdu,
      immediateCareRomanUrdu,
      confirmationRomanUrdu,
      safeHomeCare,
      safeHomeCareRomanUrdu;
  final int version;
  final List<String> species, symptoms;
}

final class HealthDiseaseResult {
  const HealthDiseaseResult({
    required this.rank,
    required this.score,
    required this.name,
    required this.code,
    required this.summary,
    required this.urgency,
    required this.immediateCare,
    required this.confirmationGuidance,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.matchedSymptoms,
    required this.missingKeySymptoms,
  });
  factory HealthDiseaseResult.fromJson(Map<String, dynamic> json) {
    final disease = json['disease'] as Map<String, dynamic>;
    return HealthDiseaseResult(
      rank: (json['rank'] as num).toInt(),
      score: double.parse(json['score'].toString()),
      name: disease['name'] as String,
      code: disease['code'] as String,
      summary: disease['summary'] as String,
      urgency: disease['urgency'] as String,
      immediateCare: disease['immediate_care'] as String,
      confirmationGuidance: disease['confirmation_guidance'] as String,
      sourceTitle: disease['source_title'] as String,
      sourceUrl: disease['source_url'] as String,
      matchedSymptoms: (json['matched_symptoms'] as List).cast<String>(),
      missingKeySymptoms: (json['missing_key_symptoms'] as List).cast<String>(),
    );
  }
  final int rank;
  final double score;
  final String name,
      code,
      summary,
      urgency,
      immediateCare,
      confirmationGuidance,
      sourceTitle,
      sourceUrl;
  final List<String> matchedSymptoms, missingKeySymptoms;
}

final class AnimalHealthCase {
  const AnimalHealthCase({
    required this.id,
    required this.caseNumber,
    required this.reportedAt,
    required this.severity,
    required this.status,
    required this.emergency,
    this.emergencyMessage,
    required this.symptoms,
    required this.differentials,
  });
  factory AnimalHealthCase.fromJson(Map<String, dynamic> json) =>
      AnimalHealthCase(
        id: json['id'] as String,
        caseNumber: json['case_number'] as String,
        reportedAt: DateTime.parse(json['reported_at'] as String),
        severity: json['severity'] as String,
        status: json['status'] as String,
        emergency: json['emergency'] as bool? ?? false,
        emergencyMessage: json['emergency_message'] as String?,
        symptoms: (json['symptoms'] as List)
            .cast<Map<String, dynamic>>()
            .map(HealthSymptom.fromJson)
            .toList(),
        differentials: (json['differentials'] as List)
            .cast<Map<String, dynamic>>()
            .map(HealthDiseaseResult.fromJson)
            .toList(),
      );
  final String id, caseNumber, severity, status;
  final DateTime reportedAt;
  final bool emergency;
  final String? emergencyMessage;
  final List<HealthSymptom> symptoms;
  final List<HealthDiseaseResult> differentials;
}

final class AnimalWithdrawal {
  const AnimalWithdrawal({
    required this.type,
    required this.endsAt,
    required this.status,
    required this.reason,
  });
  factory AnimalWithdrawal.fromJson(Map<String, dynamic> json) =>
      AnimalWithdrawal(
        type: json['type'] as String,
        endsAt: DateTime.parse(json['ends_at'] as String),
        status: json['status'] as String,
        reason: json['reason'] as String,
      );
  final String type, status, reason;
  final DateTime endsAt;
}

final class AnimalTreatment {
  const AnimalTreatment({
    required this.id,
    required this.number,
    required this.administeredAt,
    required this.dose,
    required this.doseUnit,
    required this.route,
    required this.veterinarianName,
    required this.withdrawals,
  });
  factory AnimalTreatment.fromJson(Map<String, dynamic> json) =>
      AnimalTreatment(
        id: json['id'] as String,
        number: json['treatment_number'] as String,
        administeredAt: DateTime.parse(json['administered_at'] as String),
        dose: json['dose'].toString(),
        doseUnit: json['dose_unit'] as String,
        route: json['route'] as String,
        veterinarianName: json['veterinarian_name'] as String,
        withdrawals: (json['withdrawals'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(AnimalWithdrawal.fromJson)
            .toList(),
      );
  final String id, number, dose, doseUnit, route, veterinarianName;
  final DateTime administeredAt;
  final List<AnimalWithdrawal> withdrawals;
}
