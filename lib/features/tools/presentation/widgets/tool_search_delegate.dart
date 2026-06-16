import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class ToolSearchDelegate extends SearchDelegate<String?> {
  final List<ToolItem> tools = [
    ToolItem(title: 'Mood Log', subtitle: 'How are you today?', icon: Icons.emoji_emotions_rounded, route: '/mood-checkin', color: const Color(0xFF29B6F6)),
    ToolItem(title: 'Breathing', subtitle: 'Guided breathing exercises', icon: Icons.air_rounded, route: '/breathing', color: const Color(0xFF26A69A)),
    ToolItem(title: 'AI Chat', subtitle: 'Talk to Nova AI', icon: Icons.auto_awesome_rounded, route: '/chat', color: const Color(0xFF9C27B0)),
    ToolItem(title: 'Journal', subtitle: 'Express yourself', icon: Icons.edit_note_rounded, route: '/journal', color: const Color(0xFF66BB6A)),
    ToolItem(title: 'Groups', subtitle: 'Support circles', icon: Icons.groups_rounded, route: '/groups', color: const Color(0xFF9575CD)),
    ToolItem(title: 'Gratitude', subtitle: '3 things today', icon: Icons.favorite_rounded, route: '/gratitude', color: const Color(0xFFEC407A)),
    ToolItem(title: 'Habit Tracker', subtitle: 'Build consistency', icon: Icons.checklist_rounded, route: '/habits', color: const Color(0xFFFFCA28)),
    ToolItem(title: 'AI Prediction', subtitle: 'Risk forecast', icon: Icons.batch_prediction_rounded, route: '/ai-hub', color: const Color(0xFF7E57C2)),
    ToolItem(title: 'Depression Test', subtitle: 'PHQ-9 Scale', icon: Icons.psychology_rounded, route: '/assessment/depression', color: const Color(0xFF5C6BC0)),
    ToolItem(title: 'Anxiety Test', subtitle: 'GAD-7 Scale', icon: Icons.monitor_heart_rounded, route: '/assessment/anxiety', color: const Color(0xFF42A5F5)),
    ToolItem(title: 'Stress Test', subtitle: 'PSS Scale', icon: Icons.whatshot_rounded, route: '/assessment/stress', color: const Color(0xFFEF5350)),
    ToolItem(title: 'PTSD Test', subtitle: 'PCL-5 Scale', icon: Icons.security_rounded, route: '/assessment/ptsd', color: const Color(0xFF78909C)),
    ToolItem(title: 'Panic Test', subtitle: 'Check panic symptoms', icon: Icons.flash_on_rounded, route: '/assessment/panic', color: const Color(0xFFE53935)),
    ToolItem(title: 'Burnout Test', subtitle: 'Check burnout levels', icon: Icons.local_fire_department_rounded, route: '/assessment/burnout', color: const Color(0xFF795548)),
    ToolItem(title: 'Adaptive Assessment', subtitle: 'Personalized clinical path', icon: Icons.route_rounded, route: '/adaptive-assessment/clinical_main', color: const Color(0xFFF57C00)),
    ToolItem(title: 'Grounding', subtitle: 'Reconnect with reality', icon: Icons.landscape_rounded, route: '/grounding', color: const Color(0xFF8D6E63)),
    ToolItem(title: 'Meditation', subtitle: 'Find stillness', icon: Icons.self_improvement_rounded, route: '/meditation', color: const Color(0xFF26A69A)),
    ToolItem(title: 'Sleep Mode', subtitle: 'Wind down', icon: Icons.dark_mode_rounded, route: '/sleep', color: const Color(0xFF3F51B5)),
    ToolItem(title: 'Audio Sanctuary', subtitle: 'Relax & focus', icon: Icons.headphones_rounded, route: '/audio', color: const Color(0xFFAB47BC)),
    ToolItem(title: 'Focus Timer', subtitle: 'Stay on track', icon: Icons.timer_rounded, route: '/focus', color: const Color(0xFF2196F3)),
    ToolItem(title: 'Support Plan', subtitle: 'Your safety plan', icon: Icons.assignment_rounded, route: '/support-plan', color: const Color(0xFF4CAF50)),
    ToolItem(title: 'Safe Contacts', subtitle: 'People who care', icon: Icons.contacts_rounded, route: '/safe-contacts', color: const Color(0xFF00ACC1)),
    ToolItem(title: 'Quick Help (SOS)', subtitle: 'Instant support', icon: Icons.sos_rounded, route: '/sos-mode', color: const Color(0xFFD32F2F)),
    ToolItem(title: 'Talk to Expert', subtitle: 'Private & Trusted', icon: Icons.psychology_alt_rounded, route: '/therapist/home', color: const Color(0xFF5C6BC0)),
    ToolItem(title: 'Recovery Engine', subtitle: 'MindNova Recovery', icon: Icons.healing_rounded, route: '/recovery-engine', color: const Color(0xFF00897B)),
    ToolItem(title: 'Community Feed', subtitle: 'Connect with people', icon: Icons.forum_rounded, route: '/community/feed', color: const Color(0xFF5C6BC0)),
    ToolItem(title: 'Live Circles', subtitle: 'Join guided support rooms', icon: Icons.headphones_rounded, route: '/community/live_circles', color: const Color(0xFF8E24AA)),
    ToolItem(title: 'Challenges', subtitle: 'Build healthy habits', icon: Icons.emoji_events_rounded, route: '/challenges', color: const Color(0xFFFFB300)),
  ];

  @override
  String get searchFieldLabel => 'Search tools, assessments...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFBFBFE),
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(color: const Color(0xFF2D3748), fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.inter(color: const Color(0xFFA0AEC0)),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredTools = query.isEmpty 
        ? tools 
        : tools.where((tool) => 
            tool.title.toLowerCase().contains(query.toLowerCase()) || 
            tool.subtitle.toLowerCase().contains(query.toLowerCase())
          ).toList();

    if (filteredTools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No tools found',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredTools.length,
      itemBuilder: (context, index) {
        final tool = filteredTools[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tool.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(tool.icon, color: tool.color),
          ),
          title: Text(
            tool.title,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF2D3748)),
          ),
          subtitle: Text(
            tool.subtitle,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF718096)),
          ),
          onTap: () {
            close(context, tool.route);
            context.push(tool.route);
          },
        );
      },
    );
  }
}
