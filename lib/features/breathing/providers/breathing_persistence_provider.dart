import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/breathing_model.dart';

const _storageKey = 'custom_breathing_techniques';

/// Persists user-created breathing techniques to local storage.
class BreathingPersistenceNotifier extends AsyncNotifier<List<BreathingTechnique>> {
  @override
  Future<List<BreathingTechnique>> build() async {
    return _load();
  }

  Future<List<BreathingTechnique>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return BreathingTechnique(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        inhale: map['inhale'] as int,
        holdIn: map['holdIn'] as int? ?? 0,
        exhale: map['exhale'] as int,
        holdOut: map['holdOut'] as int? ?? 0,
        targetCycles: map['targetCycles'] as int?,
      );
    }).toList();
  }

  Future<void> _save(List<BreathingTechnique> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = list.map((t) => jsonEncode({
      'id': t.id,
      'name': t.name,
      'description': t.description,
      'inhale': t.inhale,
      'holdIn': t.holdIn,
      'exhale': t.exhale,
      'holdOut': t.holdOut,
      'targetCycles': t.targetCycles,
    })).toList();
    await prefs.setStringList(_storageKey, raw);
  }

  Future<void> add(BreathingTechnique technique) async {
    final current = state.value ?? [];
    final updated = [...current, technique];
    await _save(updated);
    state = AsyncData(updated);
  }

  Future<void> remove(String id) async {
    final current = state.value ?? [];
    final updated = current.where((t) => t.id != id).toList();
    await _save(updated);
    state = AsyncData(updated);
  }
}

final customBreathingProvider =
    AsyncNotifierProvider<BreathingPersistenceNotifier, List<BreathingTechnique>>(
        BreathingPersistenceNotifier.new);
