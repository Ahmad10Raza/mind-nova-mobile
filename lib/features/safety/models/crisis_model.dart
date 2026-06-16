import 'dart:convert';

// ═══════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════

enum CrisisRiskLevel {
  low,
  med,
  high,
  severe,
  emergency,
}

enum CrisisCategory {
  suicideIdeation,
  selfHarm,
  panicAttack,
  abuse,
  depression,
  burnout,
  substanceAbuse,
  other,
}

// ═══════════════════════════════════════════════════════════
// CRISIS ANALYSIS (existing)
// ═══════════════════════════════════════════════════════════

class AppCrisisAnalysis {
  final CrisisRiskLevel riskLevel;
  final CrisisCategory category;
  final bool triggerScreen;
  final List<String> suggestions;
  final String? analysis;

  AppCrisisAnalysis({
    required this.riskLevel,
    required this.category,
    required this.triggerScreen,
    required this.suggestions,
    this.analysis,
  });

  factory AppCrisisAnalysis.fromJson(Map<String, dynamic> json) {
    return AppCrisisAnalysis(
      riskLevel: _parseRiskLevel(json['riskLevel']),
      category: _parseCategory(json['category']),
      triggerScreen: json['triggerScreen'] ?? false,
      suggestions: List<String>.from(json['suggestions'] ?? []),
      analysis: json['analysis'],
    );
  }

  static CrisisRiskLevel _parseRiskLevel(String? risk) {
    switch (risk?.toUpperCase()) {
      case 'LOW': return CrisisRiskLevel.low;
      case 'MED': return CrisisRiskLevel.med;
      case 'HIGH': return CrisisRiskLevel.high;
      case 'SEVERE': return CrisisRiskLevel.severe;
      case 'EMERGENCY': return CrisisRiskLevel.emergency;
      default: return CrisisRiskLevel.low;
    }
  }

  static CrisisCategory _parseCategory(String? cat) {
    switch (cat?.toUpperCase()) {
      case 'SUICIDE_IDEATION': return CrisisCategory.suicideIdeation;
      case 'SELF_HARM': return CrisisCategory.selfHarm;
      case 'PANIC_ATTACK': return CrisisCategory.panicAttack;
      case 'ABUSE': return CrisisCategory.abuse;
      case 'DEPRESSION': return CrisisCategory.depression;
      case 'BURNOUT': return CrisisCategory.burnout;
      case 'SUBSTANCE_ABUSE': return CrisisCategory.substanceAbuse;
      default: return CrisisCategory.other;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// SUPPORT PLAN (Crisis Plan)
// ═══════════════════════════════════════════════════════════

class SupportPlan {
  final String? id;
  final List<String> warningSigns;
  final List<String> calmingActions;
  final List<String> reasonsToStay;
  final List<String> safePlaces;
  final String? notes;
  final int version;
  final DateTime? updatedAt;

  SupportPlan({
    this.id,
    this.warningSigns = const [],
    this.calmingActions = const [],
    this.reasonsToStay = const [],
    this.safePlaces = const [],
    this.notes,
    this.version = 1,
    this.updatedAt,
  });

  factory SupportPlan.fromJson(Map<String, dynamic> json) {
    return SupportPlan(
      id: json['id'],
      warningSigns: List<String>.from(json['warningSigns'] ?? []),
      calmingActions: List<String>.from(json['calmingActions'] ?? []),
      reasonsToStay: List<String>.from(json['reasonsToStay'] ?? []),
      safePlaces: List<String>.from(json['safePlaces'] ?? []),
      notes: json['notes'],
      version: json['version'] ?? 1,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'warningSigns': warningSigns,
    'calmingActions': calmingActions,
    'reasonsToStay': reasonsToStay,
    'safePlaces': safePlaces,
    'notes': notes,
    'version': version,
  };

  /// For encrypted local storage serialization
  String toJsonString() => jsonEncode(toJson());

  factory SupportPlan.fromJsonString(String s) => SupportPlan.fromJson(jsonDecode(s));

  SupportPlan copyWith({
    String? id,
    List<String>? warningSigns,
    List<String>? calmingActions,
    List<String>? reasonsToStay,
    List<String>? safePlaces,
    String? notes,
    int? version,
    DateTime? updatedAt,
  }) {
    return SupportPlan(
      id: id ?? this.id,
      warningSigns: warningSigns ?? this.warningSigns,
      calmingActions: calmingActions ?? this.calmingActions,
      reasonsToStay: reasonsToStay ?? this.reasonsToStay,
      safePlaces: safePlaces ?? this.safePlaces,
      notes: notes ?? this.notes,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the plan has any meaningful content
  bool get isEmpty =>
      warningSigns.isEmpty &&
      calmingActions.isEmpty &&
      reasonsToStay.isEmpty &&
      safePlaces.isEmpty &&
      (notes == null || notes!.isEmpty);
}

// ═══════════════════════════════════════════════════════════
// EMERGENCY CONTACT (Trusted Contact)
// ═══════════════════════════════════════════════════════════

enum ContactRelation {
  parent('Parent'),
  sibling('Sibling'),
  partner('Partner'),
  friend('Friend'),
  mentor('Mentor'),
  counselor('Counselor'),
  other('Other');

  final String label;
  const ContactRelation(this.label);
}

class EmergencyContact {
  final String? id;
  final String name;
  final String? relation;
  final String phoneNumber;
  final int priority;
  final bool allowQuickSms;
  final bool favorite;
  final bool isVerified;
  final DateTime? verifiedAt;
  final DateTime? lastUsedAt;
  final DateTime? updatedAt;

  EmergencyContact({
    this.id,
    required this.name,
    this.relation,
    required this.phoneNumber,
    this.priority = 0,
    this.allowQuickSms = false,
    this.favorite = false,
    this.isVerified = false,
    this.verifiedAt,
    this.lastUsedAt,
    this.updatedAt,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      name: json['name'] ?? '',
      relation: json['relation'],
      phoneNumber: json['phoneNumber'] ?? '',
      priority: json['priority'] ?? 0,
      allowQuickSms: json['allowQuickSms'] ?? false,
      favorite: json['favorite'] ?? false,
      isVerified: json['isVerified'] ?? false,
      verifiedAt: json['verifiedAt'] != null ? DateTime.tryParse(json['verifiedAt']) : null,
      lastUsedAt: json['lastUsedAt'] != null ? DateTime.tryParse(json['lastUsedAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'relation': relation,
    'phoneNumber': phoneNumber,
    'priority': priority,
    'allowQuickSms': allowQuickSms,
    'favorite': favorite,
    'isVerified': isVerified,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory EmergencyContact.fromJsonString(String s) =>
      EmergencyContact.fromJson(jsonDecode(s));

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? relation,
    String? phoneNumber,
    int? priority,
    bool? allowQuickSms,
    bool? favorite,
    bool? isVerified,
    DateTime? verifiedAt,
    DateTime? lastUsedAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      priority: priority ?? this.priority,
      allowQuickSms: allowQuickSms ?? this.allowQuickSms,
      favorite: favorite ?? this.favorite,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
