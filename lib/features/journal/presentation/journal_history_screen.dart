import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/journal_provider.dart';
import '../models/journal_model.dart';
import 'widgets/journal_timeline_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class JournalHistoryScreen extends ConsumerStatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  ConsumerState<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends ConsumerState<JournalHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const _bg = Color(0xFF0F131F);
  static const _surface = Color(0xFF1B1F2C);
  static const _primary = Color(0xFFCABEFF);
  static const _secondary = Color(0xFF44E2CD);
  static const _onSurface = Color(0xFFDFE2F3);
  static const _onSurfaceVariant = Color(0xFFC9C4D8);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(journalHistoryProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(journalHistoryProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Text(
          "Journal History",
          style: GoogleFonts.manrope(
            color: _onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _onSurfaceVariant, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: historyState.isLoading && historyState.entries.isEmpty
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : historyState.entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        itemCount: historyState.entries.length + (historyState.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index == historyState.entries.length) {
                            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: _primary)));
                          }
                          final entry = historyState.entries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: JournalTimelineCard(
                              entry: entry,
                              onTap: () => context.push('/journal/editor', extra: entry),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: _bg,
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          // Add search logic if needed
        },
        style: GoogleFonts.inter(color: _onSurface),
        decoration: InputDecoration(
          hintText: "Search your thoughts...",
          hintStyle: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search_rounded, color: _onSurfaceVariant.withValues(alpha: 0.5)),
          filled: true,
          fillColor: _surface.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primary.withValues(alpha: 0.3)),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      color: _bg,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip("All Entries", true),
          _buildFilterChip("Drafts", false),
          _buildFilterChip("Favorites", false),
          _buildFilterChip("Locked", false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: Colors.transparent,
        selectedColor: _primary.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? _primary : _onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        side: BorderSide(
          color: isSelected ? _primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: _onSurfaceVariant.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            "No entries found",
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
