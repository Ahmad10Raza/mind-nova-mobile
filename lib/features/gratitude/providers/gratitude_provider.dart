import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gratitude_service.dart';
import '../models/gratitude_model.dart';
import '../../../core/network/api_client.dart';

// --- API Service Provider ---
final gratitudeServiceProvider = Provider<GratitudeService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GratitudeService(apiClient);
});

// --- Dashboard Analytics Provider ---
final gratitudeAnalyticsProvider = FutureProvider<GratitudeAnalytics>((ref) async {
  final service = ref.watch(gratitudeServiceProvider);
  return service.getAnalytics();
});

// --- Category Stats Provider ---
final gratitudeCategoriesProvider = FutureProvider<List<GratitudeCategoryStat>>((ref) async {
  final service = ref.watch(gratitudeServiceProvider);
  return service.getCategories();
});

// --- Memory Vault Provider ---
final gratitudeMemoryVaultProvider = FutureProvider<List<GratitudeMemory>>((ref) async {
  final service = ref.watch(gratitudeServiceProvider);
  return service.getMemoryVault();
});

// --- Main History Timeline State Notifier ---
class GratitudeHistoryState {
  final List<GratitudeEntry> entries;
  final bool isLoading;
  final bool hasReachedMax;

  GratitudeHistoryState({
    this.entries = const [],
    this.isLoading = true,
    this.hasReachedMax = false,
  });

  GratitudeHistoryState copyWith({
    List<GratitudeEntry>? entries,
    bool? isLoading,
    bool? hasReachedMax,
  }) {
    return GratitudeHistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class GratitudeHistoryNotifier extends Notifier<GratitudeHistoryState> {
  int _skip = 0;
  final int _take = 20;

  @override
  GratitudeHistoryState build() {
    // We cannot do async in build for a regular Notifier, but we can trigger it
    Future.microtask(() => fetchInitial());
    return GratitudeHistoryState();
  }

  GratitudeService get _service => ref.read(gratitudeServiceProvider);

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _service.getHistory(skip: 0, take: _take);
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
      final data = await _service.getHistory(skip: _skip, take: _take);
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

  Future<void> createEntry({
    String? content,
    List<String>? tags,
  }) async {
    try {
      final entry = await _service.createEntry(
        content: content,
        tags: tags,
      );
      state = state.copyWith(entries: [entry, ...state.entries]);
      _skip += 1;
      
      // Refresh analytics to update streak counts
      ref.invalidate(gratitudeAnalyticsProvider);
    } catch (e) {
      // Handle error natively / offline fallback
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final updatedEntry = await _service.toggleFavorite(id);
      state = state.copyWith(
        entries: state.entries.map((e) => e.id == id ? updatedEntry : e).toList()
      );
    } catch (e) {
      // Ignore gracefully
    }
  }
}

final gratitudeHistoryProvider = NotifierProvider<GratitudeHistoryNotifier, GratitudeHistoryState>(GratitudeHistoryNotifier.new);
