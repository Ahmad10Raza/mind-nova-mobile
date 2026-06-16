import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/grounding_model.dart';
import '../providers/grounding_provider.dart';

class _Environment {
  final SafePlaceEnvironment type;
  final String emoji;
  final String label;
  final String ambientText;
  final List<Color> colors;
  const _Environment(this.type, this.emoji, this.label, this.ambientText, this.colors);
}

final _environments = [
  _Environment(SafePlaceEnvironment.beach, "🏖️", "Beach", "Waves roll in softly. Salt air fills your lungs. The sun is warm on your skin.", [Color(0xFF0369A1), Color(0xFF0E7490)]),
  _Environment(SafePlaceEnvironment.forest, "🌲", "Forest", "Birds sing overhead. The air smells of pine and earth. Sunlight filters through the leaves.", [Color(0xFF14532D), Color(0xFF166534)]),
  _Environment(SafePlaceEnvironment.rainRoom, "🌧️", "Rainy Room", "Rain taps gently on the window. You are warm inside. The world slows down.", [Color(0xFF1E293B), Color(0xFF334155)]),
  _Environment(SafePlaceEnvironment.mountain, "⛰️", "Mountain", "The air is crisp and clear. You stand above the clouds. Everything is still.", [Color(0xFF1E3A5F), Color(0xFF1D4ED8)]),
  _Environment(SafePlaceEnvironment.fireplace, "🔥", "Fireplace", "Flames crackle softly. Warmth radiates. You are cozy, held, and safe.", [Color(0xFF7C2D12), Color(0xFF9A3412)]),
  _Environment(SafePlaceEnvironment.nightSky, "🌌", "Night Sky", "Stars fill the sky above you. The universe is vast. You are part of it.", [Color(0xFF0F0A2E), Color(0xFF1E1B4B)]),
  _Environment(SafePlaceEnvironment.garden, "🌸", "Garden", "Flowers bloom in every color. Bees hum lazily. The air is sweet.", [Color(0xFF064E3B), Color(0xFF065F46)]),
  _Environment(SafePlaceEnvironment.cozyBedroom, "🛏️", "Cozy Bedroom", "Soft pillows surround you. The lights are low. You are allowed to rest.", [Color(0xFF1C1917), Color(0xFF292524)]),
];

class SafePlaceScreen extends ConsumerStatefulWidget {
  const SafePlaceScreen({super.key});

  @override
  ConsumerState<SafePlaceScreen> createState() => _SafePlaceScreenState();
}

class _SafePlaceScreenState extends ConsumerState<SafePlaceScreen>
    with SingleTickerProviderStateMixin {
  _Environment? _selected;
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeGroundingSessionProvider.notifier).start(GroundingExerciseType.safePlace);
    });
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(activeGroundingSessionProvider.notifier).complete(
      completedFull: _selected != null,
    );
    if (mounted) context.pop();
  }

  Future<void> _saveAsFavorite() async {
    if (_selected == null) return;
    await ref.read(groundingServiceProvider).saveFavoriteEnvironment(_selected!.type);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_selected!.label} saved as favourite 🌿"),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _selected != null
              ? _selected!.colors
              : [const Color(0xFF0A0F1E), const Color(0xFF1E3A5F)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _selected == null ? _buildPicker() : _buildImmersive(),
        ),
      ),
    );
  }

  Widget _buildPicker() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _finish,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                ),
              ),
              Text("Safe Place", style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 44),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Choose your safe place", style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Where do you feel most at peace?", style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: _environments.length,
              itemBuilder: (_, i) {
                final env = _environments[i];
                return GestureDetector(
                  onTap: () => setState(() => _selected = env),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: env.colors,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: env.colors.last.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(env.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(env.label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImmersive() {
    final env = _selected!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _selected = null),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                ),
              ),
              Text(env.label, style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: _saveAsFavorite,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _floatAnim,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _floatAnim.value),
                  child: Text(env.emoji, style: const TextStyle(fontSize: 96)),
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  env.ambientText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: env.colors.first,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  child: Text("Leave this place", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
