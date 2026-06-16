import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/theme/tools_theme.dart';
import '../../providers/habit_provider.dart';
import '../../data/habit_recommendations.dart';

class HabitCreateScreen extends ConsumerStatefulWidget {
  const HabitCreateScreen({super.key});

  @override
  ConsumerState<HabitCreateScreen> createState() => _HabitCreateScreenState();
}

class _HabitCreateScreenState extends ConsumerState<HabitCreateScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Selection state
  String? _selectedCategory;
  HabitRecommendationTemplate? _selectedTemplate;
  String _customTitle = '';
  int _duration = 5;
  String _trigger = 'AFTER_WAKEUP';
  String _environment = 'HOME';

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Build Your Better Self',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? ToolsTheme.dailyGreen
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentStep = page),
              children: [
                _buildGoalStep(),
                _buildHabitStep(),
                _buildSetupStep(),
                _buildCommitStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    final categories = [
      {'name': 'MIND', 'icon': Icons.psychology, 'color': ToolsTheme.dailyGreen},
      {'name': 'BODY', 'icon': Icons.fitness_center, 'color': ToolsTheme.mindfulBlue},
      {'name': 'FOCUS', 'icon': Icons.center_focus_strong, 'color': ToolsTheme.aiPurple},
      {'name': 'RECOVERY', 'icon': Icons.battery_charging_full, 'color': ToolsTheme.assessAmber},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you want to\nimprove today?',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat['name'];
                return InkWell(
                  onTap: () {
                    setState(() => _selectedCategory = cat['name'] as String);
                    _nextPage();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (cat['color'] as Color).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? (cat['color'] as Color)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icon'] as IconData,
                            size: 48, color: cat['color'] as Color),
                        const SizedBox(height: 12),
                        Text(
                          cat['name'] as String,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStep() {
    final recommendations = habitRecommendations
        .where((r) => r.category == _selectedCategory)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a practice',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: recommendations.length + 1,
              itemBuilder: (context, index) {
                if (index == recommendations.length) {
                  return _buildCustomHabitTile();
                }
                final template = recommendations[index];
                return _buildTemplateTile(template);
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildTemplateTile(HabitRecommendationTemplate template) {
    final isSelected = _selectedTemplate == template;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTemplate = template;
            _duration = template.defaultDuration;
            _trigger = template.defaultTrigger;
          });
          _nextPage();
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? ToolsTheme.dailyGreen.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? ToolsTheme.dailyGreen
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Text(template.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHabitTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: _showCustomHabitDialog,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.add, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Text(
                'Create Custom Habit',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Refine your routine',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _buildSetupOption(
            'Trigger',
            _trigger.replaceAll('_', ' '),
            Icons.bolt,
            _showTriggerPicker,
          ),
          const SizedBox(height: 16),
          _buildSetupOption(
            'Duration',
            '$_duration minutes',
            Icons.timer,
            _showDurationPicker,
          ),
          const SizedBox(height: 16),
          _buildSetupOption(
            'Environment',
            _environment,
            Icons.place,
            _showEnvironmentPicker,
          ),
          const SizedBox(height: 40),
          _buildNavigationButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSetupOption(String label, String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: ToolsTheme.mindfulBlue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.edit, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitStep() {
    final createState = ref.watch(habitCreateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ToolsTheme.dailyGreen.withOpacity(0.1),
            ),
            child: const Text('✨', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 32),
          Text(
            'Commit to Yourself',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Smart Loop Preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ToolsTheme.dailyGreen.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _buildLoopRow('If', _trigger.replaceAll('_', ' ').toLowerCase()),
                const SizedBox(height: 12),
                _buildLoopRow('Then', _selectedTemplate?.title ?? _customTitle),
                const SizedBox(height: 12),
                _buildLoopRow('For', '$_duration minutes'),
                const SizedBox(height: 12),
                _buildLoopRow('At', _environment.toLowerCase()),
              ],
            ),
          ),
          const SizedBox(height: 40),
          if (createState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                createState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: createState.isSubmitting ? null : _submitHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ToolsTheme.dailyGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: createState.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Let\'s Start',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _previousPage,
            child: Text(
              'Wait, let me change something',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (_currentStep == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousPage,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          if (_currentStep == 2)
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: ToolsTheme.dailyGreen,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  void _showTriggerPicker() {
    final triggers = [
      {'id': 'AFTER_WAKEUP', 'label': 'After waking up', 'icon': Icons.wb_sunny_rounded},
      {'id': 'AFTER_COFFEE', 'label': 'After morning coffee', 'icon': Icons.coffee_rounded},
      {'id': 'DURING_WORK', 'label': 'During work breaks', 'icon': Icons.laptop_rounded},
      {'id': 'AFTER_WORK', 'label': 'Right after work', 'icon': Icons.home_work_rounded},
      {'id': 'BEFORE_SLEEP', 'label': 'Before going to bed', 'icon': Icons.bedtime_rounded},
      {'id': 'WHEN_STRESSED', 'label': 'When feeling stressed', 'icon': Icons.bolt_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Select a Trigger', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Cues make habits stick by creating a neural link.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: triggers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final t = triggers[i];
                  final isSelected = _trigger == t['id'];
                  return InkWell(
                    onTap: () {
                      setState(() => _trigger = t['id'] as String);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? ToolsTheme.dailyGreen.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? ToolsTheme.dailyGreen : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(t['icon'] as IconData, color: isSelected ? ToolsTheme.dailyGreen : Colors.white60, size: 20),
                          const SizedBox(width: 16),
                          Text(t['label'] as String, style: GoogleFonts.inter(fontSize: 16, color: isSelected ? Colors.white : Colors.white70)),
                          const Spacer(),
                          if (isSelected) const Icon(Icons.check_circle_rounded, color: ToolsTheme.dailyGreen, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setInner) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('How long?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$_duration', style: GoogleFonts.outfit(fontSize: 64, fontWeight: FontWeight.bold, color: ToolsTheme.dailyGreen)),
                  const SizedBox(width: 8),
                  Text('min', style: GoogleFonts.outfit(fontSize: 24, color: Colors.white38)),
                ],
              ),
              Slider(
                value: _duration.toDouble(),
                min: 1,
                max: 180,
                divisions: 179,
                activeColor: ToolsTheme.dailyGreen,
                inactiveColor: Colors.white10,
                onChanged: (v) {
                  setInner(() => _duration = v.toInt());
                  setState(() => _duration = v.toInt());
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ToolsTheme.dailyGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnvironmentPicker() {
    final venues = [
      {'id': 'HOME', 'label': 'At Home', 'icon': Icons.home_rounded},
      {'id': 'OFFICE', 'label': 'At the Office', 'icon': Icons.work_rounded},
      {'id': 'OUTDOORS', 'label': 'Outdoors', 'icon': Icons.park_rounded},
      {'id': 'GYM', 'label': 'At the Gym', 'icon': Icons.fitness_center_rounded},
      {'id': 'ANYWHERE', 'label': 'Anywhere', 'icon': Icons.public_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Where?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: venues.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final v = venues[i];
                  final isSelected = _environment == v['id'];
                  return InkWell(
                    onTap: () {
                      setState(() => _environment = v['id'] as String);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? ToolsTheme.mindfulBlue.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? ToolsTheme.mindfulBlue : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(v['icon'] as IconData, color: isSelected ? ToolsTheme.mindfulBlue : Colors.white60, size: 20),
                          const SizedBox(width: 16),
                          Text(v['label'] as String, style: GoogleFonts.inter(fontSize: 16, color: isSelected ? Colors.white : Colors.white70)),
                          const Spacer(),
                          if (isSelected) const Icon(Icons.check_circle_rounded, color: ToolsTheme.mindfulBlue, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomHabitDialog() {
    final controller = TextEditingController(text: _customTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Custom Habit', style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'What is your new habit?',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ToolsTheme.dailyGreen)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customTitle = controller.text;
                _selectedTemplate = null;
              });
              Navigator.pop(context);
              _nextPage();
            },
            child: const Text('Continue', style: TextStyle(color: ToolsTheme.dailyGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoopRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(
            label,
            style: GoogleFonts.outfit(color: ToolsTheme.dailyGreen, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Future<void> _submitHabit() async {
    final success = await ref.read(habitCreateProvider.notifier).createHabit(
          title: _selectedTemplate?.title ?? _customTitle,
          description: _selectedTemplate?.description,
          category: _selectedCategory!,
          duration: _duration,
          triggerType: _trigger,
          environment: _environment,
        );

    if (success && mounted) {
      context.pop(); // Go back to Habits Home
    }
  }
}
