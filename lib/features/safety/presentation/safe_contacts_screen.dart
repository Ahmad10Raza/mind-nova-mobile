import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/dashboard_theme.dart';
import '../../../core/theme/tools_theme.dart';
import '../providers/safety_provider.dart';
import '../models/crisis_model.dart';

class SafeContactsScreen extends ConsumerStatefulWidget {
  const SafeContactsScreen({super.key});

  @override
  ConsumerState<SafeContactsScreen> createState() => _SafeContactsScreenState();
}

class _SafeContactsScreenState extends ConsumerState<SafeContactsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    // Ensure contacts are loaded
    Future.microtask(() => ref.read(safetyProvider.notifier).loadContacts());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyProvider);
    final contacts = state.contacts;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App Bar ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: const Color(0xFFFBFBFE),
              elevation: 0,
              leading: _backButton(context),
              actions: [
                TextButton(
                  onPressed: () => context.go('/'),
                  style: TextButton.styleFrom(foregroundColor: DashboardTheme.textSecondary),
                  child: const Text('Quick Exit'),
                ),
                IconButton(
                  onPressed: () => _showAddContactSheet(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ToolsTheme.crisisRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_add_alt_1_rounded,
                        color: ToolsTheme.crisisRed, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Safe Contacts',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: DashboardTheme.textPrimary,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              ),
            ),

            // ─── Info Card ──────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFFF3E0).withOpacity(0.3),
                  ]),
                  borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
                  border: Border.all(color: Colors.orange.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.people_alt_rounded,
                          color: Colors.deepOrange, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('People you trust',
                            style: GoogleFonts.outfit(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: DashboardTheme.textPrimary,
                            )),
                          const SizedBox(height: 2),
                          Text('Quick-call or message during difficult moments.',
                            style: GoogleFonts.inter(
                              fontSize: 12, color: DashboardTheme.textTertiary,
                            )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Contacts List ──────────────────────────────
            if (contacts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _emptyState(context),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverReorderableList(
                  itemCount: contacts.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    HapticFeedback.lightImpact();
                    final item = contacts.removeAt(oldIndex);
                    contacts.insert(newIndex, item);
                    // Update priorities and save
                    final updated = contacts.asMap().entries.map((e) => e.value.copyWith(priority: e.key)).toList();
                    ref.read(safetyProvider.notifier).updateAllContacts(updated);
                  },
                  itemBuilder: (ctx, i) => KeyedSubtree(
                    key: ValueKey(contacts[i].id ?? contacts[i].phoneNumber),
                    child: _ContactCard(
                      contact: contacts[i],
                      onCall: () => _callContact(contacts[i]),
                      onMessage: () => _messageContact(contacts[i]),
                      onEdit: () => _showEditSheet(context, contacts[i]),
                      onDelete: () => _confirmDelete(context, contacts[i]),
                      onToggleFavorite: () => _toggleFavorite(contacts[i]),
                    ),
                  ),
                ),
              ),

            // Professional Support Placeholder
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services_rounded, color: Colors.grey.shade500, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Professional Support',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                            const SizedBox(height: 2),
                            Text('Coming soon to MindNova',
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Icon(Icons.lock_rounded, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContactSheet(context),
        backgroundColor: ToolsTheme.crisisRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: Text('Add Contact', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: DashboardTheme.textPrimary),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_add_rounded, size: 40, color: Colors.deepOrange),
          ),
          const SizedBox(height: 20),
          Text('No contacts yet',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700,
                color: DashboardTheme.textPrimary)),
          const SizedBox(height: 8),
          SizedBox(
            width: 260,
            child: Text(
              'Add people you trust. They\'ll be a quick tap away when you need support.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: DashboardTheme.textTertiary, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddContactSheet(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text('Add Your First Contact', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: ToolsTheme.crisisRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────

  void _callContact(EmergencyContact c) {
    HapticFeedback.mediumImpact();
    if (c.id != null) ref.read(safetyProvider.notifier).markContactUsed(c.id!);
    launchUrl(Uri.parse('tel:${c.phoneNumber}'));
  }

  void _messageContact(EmergencyContact c) {
    HapticFeedback.lightImpact();
    if (c.id != null) ref.read(safetyProvider.notifier).markContactUsed(c.id!);
    const msg = "Hey, I'm using MindNova and wanted to reach out. Hope you're doing well ❤️";
    launchUrl(Uri.parse('sms:${c.phoneNumber}?body=${Uri.encodeComponent(msg)}'));
  }

  void _toggleFavorite(EmergencyContact c) {
    HapticFeedback.lightImpact();
    ref.read(safetyProvider.notifier).updateContact(
      c.copyWith(favorite: !c.favorite),
    );
  }

  void _confirmDelete(BuildContext ctx, EmergencyContact c) {
    showDialog(
      context: ctx,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove ${c.name}?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text('This contact will be removed from your safe list.',
            style: GoogleFonts.inter(color: DashboardTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d),
            child: Text('Cancel', style: GoogleFonts.inter(color: DashboardTheme.textTertiary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(d);
              if (c.id != null) ref.read(safetyProvider.notifier).deleteContact(c.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ToolsTheme.crisisRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddContactSheet(BuildContext ctx) =>
      _showContactSheet(ctx, null);

  void _showEditSheet(BuildContext ctx, EmergencyContact c) =>
      _showContactSheet(ctx, c);

  void _showContactSheet(BuildContext ctx, EmergencyContact? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phoneNumber ?? '');
    String? relation = existing?.relation;
    bool allowSms = existing?.allowQuickSms ?? false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    existing == null ? 'Add Contact' : 'Edit Contact',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  _sheetField(nameCtrl, 'Name', Icons.person_rounded),
                  const SizedBox(height: 12),
                  _sheetField(phoneCtrl, 'Phone Number', Icons.phone_rounded,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  // Relation dropdown
                  DropdownButtonFormField<String>(
                    value: relation,
                    decoration: _sheetInputDecor('Relationship', Icons.favorite_rounded),
                    items: ContactRelation.values.map((r) =>
                      DropdownMenuItem(value: r.label, child: Text(r.label))).toList(),
                    onChanged: (v) => setSheetState(() => relation = v),
                  ),
                  const SizedBox(height: 12),
                  // Quick SMS toggle
                  SwitchListTile(
                    value: allowSms,
                    onChanged: (v) => setSheetState(() => allowSms = v),
                    title: Text('Allow Quick SMS',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('Send pre-written message in SOS mode',
                        style: GoogleFonts.inter(fontSize: 12, color: DashboardTheme.textTertiary)),
                    activeColor: ToolsTheme.crisisRed,
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final phone = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');

                        if (name.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and phone number.')));
                          return;
                        }

                        if (phone.length < 7 || phone.length > 15) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid phone number format.')));
                          return;
                        }

                        // Duplicate prevention
                        final allContacts = ref.read(safetyProvider).contacts;
                        if (existing == null && allContacts.any((c) => c.phoneNumber.replaceAll(RegExp(r'\D'), '') == phone)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This contact already exists.')));
                          return;
                        }

                        HapticFeedback.mediumImpact();
                        final contact = EmergencyContact(
                          id: existing?.id,
                          name: name,
                          phoneNumber: phoneCtrl.text.trim(),
                          relation: relation,
                          allowQuickSms: allowSms,
                          priority: existing?.priority ?? 0,
                          favorite: existing?.favorite ?? false,
                        );
                        if (existing == null) {
                          ref.read(safetyProvider.notifier).addContact(contact);
                        } else {
                          ref.read(safetyProvider.notifier).updateContact(contact);
                        }
                        Navigator.pop(sheetCtx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ToolsTheme.crisisRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(existing == null ? 'Add Contact' : 'Save Changes',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: _sheetInputDecor(label, icon),
    );
  }

  InputDecoration _sheetInputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: DashboardTheme.textTertiary),
      prefixIcon: Icon(icon, size: 20, color: DashboardTheme.textTertiary),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CONTACT CARD WIDGET
// ═══════════════════════════════════════════════════════════

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _ContactCard({
    required this.contact,
    required this.onCall,
    required this.onMessage,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: contact.favorite
              ? ToolsTheme.crisisRed.withOpacity(0.2)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: contact.favorite
                          ? [ToolsTheme.crisisRed, const Color(0xFFFF8A80)]
                          : [Colors.grey.shade200, Colors.grey.shade300],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                      style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: contact.favorite ? Colors.white : DashboardTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name + Relation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(contact.name,
                              style: GoogleFonts.outfit(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: DashboardTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.favorite) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.star_rounded, size: 16, color: ToolsTheme.crisisRed),
                          ],
                        ],
                      ),
                      if (contact.relation != null)
                        Text(contact.relation!,
                          style: GoogleFonts.inter(
                            fontSize: 12, color: DashboardTheme.textTertiary,
                          )),
                    ],
                  ),
                ),
                // Quick actions
                _actionButton(Icons.call_rounded, const Color(0xFF43A047), onCall),
                const SizedBox(width: 6),
                _actionButton(Icons.message_rounded, const Color(0xFF1E88E5), onMessage),
              ],
            ),
            const SizedBox(height: 10),
            // Bottom row: fav + edit + delete
            Row(
              children: [
                _chipButton(
                  contact.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  contact.favorite ? 'Favorited' : 'Favorite',
                  contact.favorite ? ToolsTheme.crisisRed : DashboardTheme.textTertiary,
                  onToggleFavorite,
                ),
                const Spacer(),
                _chipButton(Icons.edit_rounded, 'Edit', DashboardTheme.textTertiary, onEdit),
                const SizedBox(width: 8),
                _chipButton(Icons.delete_outline_rounded, 'Remove',
                    DashboardTheme.textTertiary, onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _chipButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
