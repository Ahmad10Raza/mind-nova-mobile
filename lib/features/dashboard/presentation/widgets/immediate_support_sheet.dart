import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/theme/tools_theme.dart';

class ImmediateSupportSheet {
  static void show(BuildContext ctx) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: ToolsTheme.emergencyGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Immediate Support',
                          style: GoogleFonts.outfit(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                        Text('You\'re safe. Pick what feels right.',
                          style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white54,
                          )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick actions grid
              Row(
                children: [
                  _sheetAction(
                    icon: Icons.call_rounded,
                    label: 'Call 112',
                    color: const Color(0xFF43A047),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      launchUrl(Uri.parse('tel:112'));
                    },
                  ),
                  const SizedBox(width: 12),
                  _sheetAction(
                    icon: Icons.textsms_rounded,
                    label: 'Text Line',
                    color: const Color(0xFF1E88E5),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      launchUrl(Uri.parse(
                          'sms:741741?body=${Uri.encodeComponent("HOME")}'));
                    },
                  ),
                  const SizedBox(width: 12),
                  _sheetAction(
                    icon: Icons.sos_rounded,
                    label: 'SOS Mode',
                    color: DashboardTheme.crisisRed,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.push('/sos-mode');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _sheetAction(
                    icon: Icons.assignment_rounded,
                    label: 'My Plan',
                    color: const Color(0xFFFF8A65),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.push('/support-plan');
                    },
                  ),
                  const SizedBox(width: 12),
                  _sheetAction(
                    icon: Icons.air_rounded,
                    label: 'Breathe',
                    color: const Color(0xFF26A69A),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.push('/breathing');
                    },
                  ),
                  const SizedBox(width: 12),
                  _sheetAction(
                    icon: Icons.contacts_rounded,
                    label: 'Contacts',
                    color: const Color(0xFFFFAB91),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.push('/safe-contacts');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Reassurance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: Color(0xFFEF9A9A), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'It takes courage to seek help. We\'re proud of you.',
                        style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white60, height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _sheetAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color,
                )),
            ],
          ),
        ),
      ),
    );
  }
}
