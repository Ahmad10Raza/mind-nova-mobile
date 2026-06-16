import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/crisis_model.dart';

// ═══════════════════════════════════════════════════════════
// EMERGENCY RESOURCE (helpline model — kept here for backward compat)
// ═══════════════════════════════════════════════════════════

class EmergencyResource {
  final String id;
  final String name;
  final String? description;
  final String phoneNumber;
  final String? website;

  EmergencyResource({
    required this.id,
    required this.name,
    this.description,
    required this.phoneNumber,
    this.website,
  });

  factory EmergencyResource.fromJson(Map<String, dynamic> json) {
    return EmergencyResource(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      phoneNumber: json['phoneNumber'],
      website: json['website'],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SAFETY SERVICE
// ═══════════════════════════════════════════════════════════

class SafetyService {
  final ApiClient _apiClient;

  SafetyService(this._apiClient);

  // ─── Emergency Resources ──────────────────────────────────

  Future<List<EmergencyResource>> getResources({String? country, String? region}) async {
    try {
      final response = await _apiClient.get(
        '/crisis/resources',
        queryParameters: {
          if (country != null) 'country': country,
          if (region != null) 'region': region,
        },
      );
      
      return (response.data as List)
          .map((json) => EmergencyResource.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to fetch resources: $e');
      return [];
    }
  }

  // ─── Support Plan ─────────────────────────────────────────

  Future<SupportPlan?> getPlan() async {
    try {
      final response = await _apiClient.get('/crisis/plan');
      return SupportPlan.fromJson(response.data);
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to fetch plan: $e');
      return null;
    }
  }

  Future<SupportPlan?> savePlan(SupportPlan plan) async {
    try {
      final response = await _apiClient.post('/crisis/plan', data: plan.toJson());
      return SupportPlan.fromJson(response.data);
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to save plan: $e');
      return null;
    }
  }

  // ─── Trusted Contacts ─────────────────────────────────────

  Future<List<EmergencyContact>> getContacts() async {
    try {
      final response = await _apiClient.get('/crisis/contacts');
      return (response.data as List)
          .map((json) => EmergencyContact.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to fetch contacts: $e');
      return [];
    }
  }

  Future<EmergencyContact?> addContact(EmergencyContact contact) async {
    try {
      final response = await _apiClient.post('/crisis/contacts', data: contact.toJson());
      return EmergencyContact.fromJson(response.data);
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to add contact: $e');
      return null;
    }
  }

  Future<EmergencyContact?> updateContact(EmergencyContact contact) async {
    try {
      final response = await _apiClient.put('/crisis/contacts/${contact.id}', data: contact.toJson());
      return EmergencyContact.fromJson(response.data);
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to update contact: $e');
      return null;
    }
  }

  Future<bool> deleteContact(String contactId) async {
    try {
      await _apiClient.delete('/crisis/contacts/$contactId');
      return true;
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to delete contact: $e');
      return false;
    }
  }

  Future<void> markContactUsed(String contactId) async {
    try {
      await _apiClient.post('/crisis/contacts/$contactId/used');
    } catch (e) {
      // Fire-and-forget
    }
  }

  // ─── SOS + Events ─────────────────────────────────────────

  Future<void> triggerSos() async {
    try {
      await _apiClient.post('/crisis/sos/trigger');
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to trigger SOS: $e');
    }
  }

  Future<void> markSafe() async {
    try {
      await _apiClient.post('/crisis/mark-safe');
    } catch (e) {
      debugPrint('⚠️ [SafetyService] Failed to mark safe: $e');
    }
  }

  Future<void> logEvent({required String source, String? action}) async {
    try {
      await _apiClient.post('/crisis/log-event', data: {
        'source': source,
        if (action != null) 'action': action,
      });
    } catch (e) {
      // Fire-and-forget logging — never block UI
    }
  }
}
