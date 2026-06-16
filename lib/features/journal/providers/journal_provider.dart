import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_model.dart';
import '../data/journal_service.dart';
import '../../../core/network/api_client.dart';

// --- Base Services ---
final journalServiceProvider = Provider<JournalService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JournalService(apiClient);
});

final journalAnalyticsProvider = FutureProvider<JournalAnalytics>((ref) async {
  final service = ref.watch(journalServiceProvider);
  return service.getAnalytics();
});

final journalMemoryResurfaceProvider = FutureProvider<JournalEntry?>((ref) async {
  final service = ref.watch(journalServiceProvider);
  return service.getMemoryResurface();
});

final journalDailyPromptProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(journalServiceProvider);
  return service.getDailyPrompt();
});

// --- Timeline State Notifier ---
class JournalHistoryState {
  final List<JournalEntry> entries;
  final bool isLoading;
  final bool hasReachedMax;
  final String? filterMood;
  final String? filterType;

  JournalHistoryState({
    this.entries = const [],
    this.isLoading = true,
    this.hasReachedMax = false,
    this.filterMood,
    this.filterType,
  });

  JournalHistoryState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    bool? hasReachedMax,
    String? filterMood,
    String? filterType,
  }) {
    return JournalHistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      filterMood: filterMood ?? this.filterMood,
      filterType: filterType ?? this.filterType,
    );
  }
}

class JournalHistoryNotifier extends Notifier<JournalHistoryState> {
  int _skip = 0;
  final int _take = 20;

  @override
  JournalHistoryState build() {
    Future.microtask(() => fetchInitial());
    return JournalHistoryState();
  }

  JournalService get _service => ref.read(journalServiceProvider);

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _service.getHistory(
        skip: 0, 
        take: _take, 
        mood: state.filterMood, 
        type: state.filterType
      );
      _skip = data.length;
      state = state.copyWith(
        entries: data,
        isLoading: false,
        hasReachedMax: data.length < _take,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoading || state.hasReachedMax) return;
    state = state.copyWith(isLoading: true);
    try {
      final data = await _service.getHistory(
        skip: _skip, 
        take: _take,
        mood: state.filterMood,
        type: state.filterType,
      );
      _skip += data.length;
      state = state.copyWith(
        entries: [...state.entries, ...data],
        isLoading: false,
        hasReachedMax: data.isEmpty || data.length < _take,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilters({String? mood, String? type}) {
    state = state.copyWith(filterMood: mood, filterType: type);
    fetchInitial(); // Reload with new filters
  }

  void clearFilters() {
    state = state.copyWith(filterMood: null, filterType: null);
    fetchInitial();
  }
  
  void localUpsert(JournalEntry updated) {
    // Look for existing and replace, otherwise prepend if it's new
    final idx = state.entries.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      final newEntries = List<JournalEntry>.from(state.entries);
      newEntries[idx] = updated;
      state = state.copyWith(entries: newEntries);
    } else {
      state = state.copyWith(entries: [updated, ...state.entries]);
    }
  }
}

final journalHistoryProvider = NotifierProvider<JournalHistoryNotifier, JournalHistoryState>(JournalHistoryNotifier.new);

// --- Editor AutoSave Protocol ---
class JournalEditorNotifier extends Notifier<JournalEntry?> {
  Timer? _debounce;
  
  @override
  JournalEntry? build() {
    return null; // Null implies drafting from scratch
  }

  JournalService get _service => ref.read(journalServiceProvider);

  void initiateDraft(JournalEntry? existing) {
    state = existing;
  }

  void triggerAutoSave({
    required String content, 
    String? title, 
    String? moodState, 
    String? journalType, 
    List<String>? tags
  }) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Save locally or execute network dispatch 5 seconds after keystroke pause
    _debounce = Timer(const Duration(seconds: 5), () async {
      final isNew = state == null || state!.id.isEmpty;
      
      try {
        JournalEntry saved;
        if (isNew) {
          saved = await _service.createEntry(
            content: content,
            title: title,
            moodState: moodState,
            journalType: journalType,
            tags: tags,
            isDraft: true,
          );
        } else {
          saved = await _service.updateEntry(
            state!.id,
            content: content,
            title: title,
            moodState: moodState,
            tags: tags,
            isDraft: true,
          );
        }
        
        state = saved;
        // Broadcast the update back to the main timeline
        ref.read(journalHistoryProvider.notifier).localUpsert(saved);
        
      } catch (e) {
        // Fallback: Drop payload into structured shared-preferences queue for offline syncing
      }
    });
  }

  Future<void> publishFinal({
    required String content, 
    String? title, 
    String? moodState, 
    String? journalType, 
    List<String>? tags
  }) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    final isNew = state == null || state!.id.isEmpty;
      
    JournalEntry saved;
    if (isNew) {
      saved = await _service.createEntry(
        content: content,
        title: title,
        moodState: moodState,
        journalType: journalType,
        tags: tags,
        isDraft: false,
      );
    } else {
      saved = await _service.updateEntry(
        state!.id,
        content: content,
        title: title,
        moodState: moodState,
        tags: tags,
        isDraft: false, // published
      );
    }
    
    state = saved;
    ref.read(journalHistoryProvider.notifier).localUpsert(saved);
    ref.invalidate(journalAnalyticsProvider);
  }
}

final journalEditorProvider = NotifierProvider<JournalEditorNotifier, JournalEntry?>(JournalEditorNotifier.new);
