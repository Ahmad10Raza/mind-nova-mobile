import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mood_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'mood_log_provider.dart';

// ─── Utility ─────────────────────────────────────────────────────────────────

bool _isAuthenticated(WidgetRef ref) {
  final auth = ref.read(authProvider);
  return auth.status == AuthStatus.authenticated || auth.status == AuthStatus.anonymous;
}

bool _isAuthenticatedFromRef(Ref ref) {
  final auth = ref.read(authProvider);
  return auth.status == AuthStatus.authenticated;
}

// ─── Home Widget Provider (1-min cache) ──────────────────────────────────────

final moodHomeWidgetProvider = FutureProvider<MoodHomeWidget>((ref) async {
  ref.watch(authProvider);
  if (!_isAuthenticatedFromRef(ref)) {
    return const MoodHomeWidget(
      hasLogs: false,
      insightMessage: 'Sign in to see your emotional summary.',
      sparkline: [],
      streaks: MoodStreaks(),
    );
  }

  final service = ref.read(moodServiceProvider);
  try {
    final data = await service.getHomeWidget();
    // Cache to local storage as offline fallback
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_home_widget', jsonEncode({
      'hasLogs': data.hasLogs,
      'latestMood': data.latestMood,
      'latestCategory': data.latestCategory,
      'latestEmoji': data.latestEmoji,
      'latestColor': data.latestColor,
      'loggedAt': data.loggedAt?.toIso8601String(),
      'insightMessage': data.insightMessage,
      'sparkline': data.sparkline,
      'streaks': {
        'dailyCheckin': data.streaks.dailyCheckin,
        'longest': data.streaks.longest,
        'positiveMood': data.streaks.positiveMood,
        'calmDay': data.streaks.calmDay,
      },
    }));
    return data;
  } catch (_) {
    // Offline fallback: serve last cached version
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_home_widget');
    if (cached != null) {
      return MoodHomeWidget.fromJson(jsonDecode(cached));
    }
    rethrow;
  }
});

// ─── Analytics Summary Provider (5-min cache, family) ────────────────────────

final moodAnalyticsSummaryProvider = FutureProvider.family<MoodAnalyticsSummary, int>((ref, days) async {
  ref.watch(authProvider);
  if (!_isAuthenticatedFromRef(ref)) return const MoodAnalyticsSummary(hasData: false);
  final service = ref.read(moodServiceProvider);
  return service.getAnalyticsSummary(days: days);
});

// ─── Distribution Provider ───────────────────────────────────────────────────

final moodDistributionProvider = FutureProvider.family<MoodDistribution, int>((ref, days) async {
  if (!_isAuthenticatedFromRef(ref)) return const MoodDistribution(hasData: false);
  final service = ref.read(moodServiceProvider);
  return service.getMoodDistribution(days: days);
});

// ─── Trigger Analysis Provider ───────────────────────────────────────────────

final triggerAnalysisProvider = FutureProvider.family<TriggerAnalysis, int>((ref, days) async {
  if (!_isAuthenticatedFromRef(ref)) return const TriggerAnalysis(hasData: false);
  final service = ref.read(moodServiceProvider);
  return service.getTriggerAnalysis(days: days);
});

// ─── Recovery Effectiveness Provider (1-hour cache) ──────────────────────────

final recoveryEffectivenessProvider = FutureProvider.family<RecoveryEffectiveness, int>((ref, days) async {
  if (!_isAuthenticatedFromRef(ref)) return const RecoveryEffectiveness(hasData: false);
  final service = ref.read(moodServiceProvider);
  return service.getRecoveryEffectiveness(days: days);
});

// ─── Weekly Insights Provider (30-minute cache) ───────────────────────────────

final weeklyInsightsProvider = FutureProvider.family<WeeklyInsights, int>((ref, days) async {
  if (!_isAuthenticatedFromRef(ref)) return const WeeklyInsights(insights: []);
  final service = ref.read(moodServiceProvider);
  return service.getWeeklyInsights(days: days);
});

// ─── Reflection Highlights Provider ───────────────────────────────────────────

final reflectionHighlightsProvider = FutureProvider<ReflectionHighlightsData>((ref) async {
  if (!_isAuthenticatedFromRef(ref)) return const ReflectionHighlightsData(hasData: false);
  final service = ref.read(moodServiceProvider);
  return service.getReflectionHighlights();
});

// ─── Nova Suggests Provider ───────────────────────────────────────────────────

final novaSuggestsProvider = FutureProvider<NovaSuggestion>((ref) async {
  if (!_isAuthenticatedFromRef(ref)) {
    return const NovaSuggestion(title: 'Nova Suggests', body: 'Start your journey by checking in today. Reflection helps build emotional resilience over time.', actionLabel: 'Check In', actionRoute: '/mood-checkin');
  }
  final service = ref.read(moodServiceProvider);
  return service.getNovaSuggests();
});

// ─── Paginated History Notifier ───────────────────────────────────────────────

class MoodHistoryState {
  final List<MoodHistoryEntry> entries;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String? activeFilter; // category filter
  final String searchQuery;

  const MoodHistoryState({
    this.entries = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
    this.activeFilter,
    this.searchQuery = '',
  });

  MoodHistoryState copyWith({
    List<MoodHistoryEntry>? entries,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
    String? activeFilter,
    String? searchQuery,
  }) {
    return MoodHistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<MoodHistoryEntry> get filteredEntries {
    var result = entries;
    if (activeFilter != null && activeFilter!.isNotEmpty) {
      result = result.where((e) => e.category == activeFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((e) =>
        e.moodName.toLowerCase().contains(q) ||
        e.tags.any((t) => t.toLowerCase().contains(q)) ||
        (e.notes?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    return result;
  }

  /// Group entries by Today / Yesterday / This Week / This Month / Earlier
  Map<String, List<MoodHistoryEntry>> get groupedEntries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));
    final thisMonth = DateTime(now.year, now.month, 1);

    final groups = <String, List<MoodHistoryEntry>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'This Month': [],
      'Earlier': [],
    };

    for (final e in filteredEntries) {
      final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      if (d == today) {
        groups['Today']!.add(e);
      } else if (d == yesterday) {
        groups['Yesterday']!.add(e);
      } else if (d.isAfter(thisWeek)) {
        groups['This Week']!.add(e);
      } else if (d.isAfter(thisMonth)) {
        groups['This Month']!.add(e);
      } else {
        groups['Earlier']!.add(e);
      }
    }

    // Remove empty groups
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }
}

class MoodHistoryNotifier extends Notifier<MoodHistoryState> {
  @override
  MoodHistoryState build() {
    Future.microtask(() => fetchNextPage(reset: true));
    return const MoodHistoryState();
  }

  Future<void> fetchNextPage({bool reset = false}) async {
    if (state.isLoading) return;
    if (!reset && !state.hasMore) return;

    final authState = ref.read(authProvider);
    if (authState.status != AuthStatus.authenticated) {
      state = const MoodHistoryState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final nextPage = reset ? 1 : state.currentPage + 1;
    try {
      final service = ref.read(moodServiceProvider);
      final result = await service.getMoodHistoryPaged(page: nextPage);
      final newEntries = reset ? result.data : [...state.entries, ...result.data];
      state = state.copyWith(
        entries: newEntries,
        isLoading: false,
        hasMore: result.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String? category) {
    state = state.copyWith(activeFilter: category);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() => fetchNextPage(reset: true);
}

final moodHistoryProvider = NotifierProvider<MoodHistoryNotifier, MoodHistoryState>(MoodHistoryNotifier.new);

// ─── Legacy Analytics State (for backward compat with MoodHistoryScreen) ─────

class AnalyticsState {
  final List<MoodTrend> trends;
  final MoodInsights? insights;
  final bool isLoading;
  final String? error;
  final int rangeInDays;

  AnalyticsState({
    required this.trends,
    this.insights,
    this.isLoading = false,
    this.error,
    this.rangeInDays = 7,
  });

  AnalyticsState copyWith({
    List<MoodTrend>? trends,
    MoodInsights? insights,
    bool? isLoading,
    String? error,
    int? rangeInDays,
  }) {
    return AnalyticsState(
      trends: trends ?? this.trends,
      insights: insights ?? this.insights,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      rangeInDays: rangeInDays ?? this.rangeInDays,
    );
  }
}

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  late int arg;

  @override
  AnalyticsState build() {
    ref.watch(authProvider);
    Future.microtask(() => fetchAnalytics(days: arg));
    return AnalyticsState(trends: [], rangeInDays: arg);
  }

  Future<void> fetchAnalytics({int? days}) async {
    final authState = ref.read(authProvider);
    final range = days ?? state.rangeInDays;
    state = state.copyWith(isLoading: true, error: null, rangeInDays: range);

    if (authState.status == AuthStatus.anonymous || authState.status == AuthStatus.unauthenticated) {
      state = state.copyWith(trends: [], insights: null, isLoading: false);
      return;
    }

    try {
      final service = ref.read(moodServiceProvider);
      final trends = await service.getMoodTrends(days: range);
      state = state.copyWith(trends: trends, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to fetch analytics: ${e.toString()}');
    }
  }
}

final analyticsProvider = NotifierProvider.family<AnalyticsNotifier, AnalyticsState, int>((arg) {
  return AnalyticsNotifier()..arg = arg;
});
