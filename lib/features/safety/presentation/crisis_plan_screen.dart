import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/dashboard_theme.dart';
import '../../../core/theme/tools_theme.dart';
import '../providers/safety_provider.dart';
import '../models/crisis_model.dart';

/// User-facing name: "My Support Plan"
/// Internal: crisis_plan_screen
class CrisisPlanScreen extends ConsumerStatefulWidget {
  const CrisisPlanScreen({super.key});

  @override
  ConsumerState<CrisisPlanScreen> createState() => _CrisisPlanScreenState();
}

class _CrisisPlanScreenState extends ConsumerState<CrisisPlanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  Timer? _debounce;
  final _notesController = TextEditingController();
  bool _hasUnsavedChanges = false;

  // Working copies (editable)
  List<String> _warningSigns = [];
  List<String> _calmingActions = [];
  List<String> _reasonsToStay = [];
  List<String> _safePlaces = [];

  // Preset suggestions
  static const _warningPresets = [
    'Feeling overwhelmed',
    'Sleeping too much/little',
    'Withdrawing from friends',
    'Loss of appetite',
    'Racing thoughts',
    'Feeling hopeless',
    'Difficulty concentrating',
    'Irritability',
  ];

  static const _calmingPresets = [
    'Deep breathing',
    'Go for a walk',
    'Listen to music',
    'Call a friend',
    'Take a warm shower',
    'Write in journal',
    'Meditate',
    'Pet my animal',
    'Drink warm tea',
    'Count to 10 slowly',
  ];

  static const _reasonsPresets = [
    'My family',
    'My pets',
    'My dreams and goals',
    'People who love me',
    'Things I want to experience',
    'The good days ahead',
    'My favorite memories',
    'Making a difference',
  ];

  static const _placesPresets = [
    'My room',
    'A park nearby',
    'Library',
    'Coffee shop',
    'Friend\'s house',
    'Nature trail',
    'Beach',
    'My car (parked)',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    _loadPlan();
  }

  void _loadPlan() {
    final plan = ref.read(safetyProvider).plan;
    if (plan != null) {
      setState(() {
        _warningSigns = List.from(plan.warningSigns);
        _calmingActions = List.from(plan.calmingActions);
        _reasonsToStay = List.from(plan.reasonsToStay);
        _safePlaces = List.from(plan.safePlaces);
        _notesController.text = plan.notes ?? '';
      });
    }
  }

  void _scheduleAutoSave() {
    _hasUnsavedChanges = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), _save);
  }

  Future<void> _save() async {
    if (!_hasUnsavedChanges) return;
    final plan = SupportPlan(
      warningSigns: _warningSigns,
      calmingActions: _calmingActions,
      reasonsToStay: _reasonsToStay,
      safePlaces: _safePlaces,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    await ref.read(safetyProvider.notifier).savePlan(plan);
    _hasUnsavedChanges = false;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plan saved ✓', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_hasUnsavedChanges) _save();
    _debounce?.cancel();
    _notesController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App Bar ───────────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: const Color(0xFFFBFBFE),
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: DashboardTheme.textPrimary),
                ),
                onPressed: () {
                  if (_hasUnsavedChanges) _save();
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                TextButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(foregroundColor: DashboardTheme.primaryPurple),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'My Support Plan',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: DashboardTheme.textPrimary,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              ),
            ),

            // ─── Intro Card ──────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ToolsTheme.crisisBgTint,
                      ToolsTheme.crisisBgTint.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
                  border: Border.all(color: ToolsTheme.crisisRed.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ToolsTheme.crisisRed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.shield_rounded,
                          color: ToolsTheme.crisisRed.withOpacity(0.8), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your personal safety guide',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: DashboardTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Saved securely on your device. Only you can see this.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: DashboardTheme.textTertiary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Section 1: Warning Signs ────────────────────
            _buildSection(
              title: 'Warning Signs',
              subtitle: 'What tells you things might be getting hard?',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFF9800),
              items: _warningSigns,
              presets: _warningPresets,
              onChanged: (items) {
                setState(() => _warningSigns = items);
                _scheduleAutoSave();
              },
            ),

            // ─── Section 2: What Helps Me ────────────────────
            _buildSection(
              title: 'What Helps Me',
              subtitle: 'Actions that bring you calm and comfort.',
              icon: Icons.spa_rounded,
              color: const Color(0xFF66BB6A),
              items: _calmingActions,
              presets: _calmingPresets,
              onChanged: (items) {
                setState(() => _calmingActions = items);
                _scheduleAutoSave();
              },
            ),

            // ─── Section 3: Reasons to Keep Going ────────────
            _buildSection(
              title: 'Reasons to Keep Going',
              subtitle: 'People, dreams, and things you cherish.',
              icon: Icons.favorite_rounded,
              color: const Color(0xFFE91E63),
              items: _reasonsToStay,
              presets: _reasonsPresets,
              onChanged: (items) {
                setState(() => _reasonsToStay = items);
                _scheduleAutoSave();
              },
            ),

            // ─── Section 4: Safe Places ──────────────────────
            _buildSection(
              title: 'My Safe Places',
              subtitle: 'Where do you feel most at peace?',
              icon: Icons.home_rounded,
              color: const Color(0xFF29B6F6),
              items: _safePlaces,
              presets: _placesPresets,
              onChanged: (items) {
                setState(() => _safePlaces = items);
                _scheduleAutoSave();
              },
            ),

            // ─── Section 5: Notes ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: DashboardTheme.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.edit_note_rounded,
                          color: DashboardTheme.primaryPurple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Personal Notes',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: DashboardTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 4,
                    onChanged: (_) => _scheduleAutoSave(),
                    style: GoogleFonts.inter(fontSize: 14, color: DashboardTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Anything else you want to remember...',
                      hintStyle: GoogleFonts.inter(color: DashboardTheme.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // ─── Section Builder ────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> items,
    required List<String> presets,
    required ValueChanged<List<String>> onChanged,
  }) {
    // Presets not yet added by user
    final available = presets.where((p) => !items.contains(p)).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: DashboardTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: DashboardTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Added items (chips)
            if (items.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) {
                  return AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Chip(
                      label: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      backgroundColor: color.withOpacity(0.08),
                      side: BorderSide(color: color.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      deleteIcon: Icon(Icons.close_rounded, size: 16, color: color),
                      onDeleted: () {
                        HapticFeedback.lightImpact();
                        final updated = List<String>.from(items)..remove(item);
                        onChanged(updated);
                      },
                    ),
                  );
                }).toList(),
              ),

            if (items.isNotEmpty) const SizedBox(height: 12),

            // Suggestions (presets not yet added)
            if (available.isNotEmpty) ...[
              Text(
                'Suggestions',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DashboardTheme.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: available.take(5).map((preset) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final updated = List<String>.from(items)..add(preset);
                      onChanged(updated);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 14, color: DashboardTheme.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            preset,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: DashboardTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 8),

            // Add custom button
            GestureDetector(
              onTap: () => _showAddCustomDialog(title, color, items, onChanged),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: color.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'Add your own',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade100, height: 1),
          ],
        ),
      ),
    );
  }

  void _showAddCustomDialog(
    String sectionTitle,
    Color color,
    List<String> items,
    ValueChanged<List<String>> onChanged,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Add to $sectionTitle',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Type something...',
            hintStyle: GoogleFonts.inter(color: DashboardTheme.textTertiary),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              HapticFeedback.lightImpact();
              onChanged([...items, value.trim()]);
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: DashboardTheme.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                HapticFeedback.lightImpact();
                onChanged([...items, controller.text.trim()]);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
