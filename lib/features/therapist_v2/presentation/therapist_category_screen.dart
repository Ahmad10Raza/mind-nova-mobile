import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../therapist/providers/therapist_provider.dart';
import '../../therapist/models/therapist_model.dart';

const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);

class TherapistCategoryScreen extends ConsumerWidget {
  final String category;

  const TherapistCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredTherapistsProvider);

    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -100, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          Positioned(bottom: -50, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()))),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: featuredAsync.when(
                    data: (therapists) {
                      // Simple filter: Check if category is mentioned in specialty, title, bio, or styleTags
                      final catLower = category.toLowerCase();
                      final filtered = therapists.where((t) {
                        return t.specialty.toLowerCase().contains(catLower) ||
                               t.title.toLowerCase().contains(catLower) ||
                               t.bio.toLowerCase().contains(catLower) ||
                               t.styleTags.any((tag) => tag.toLowerCase().contains(catLower));
                      }).toList();

                      if (filtered.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildTherapistCard(context, filtered[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: _primaryColor)),
                    error: (err, stack) => Center(child: Text('Error loading therapists: $err', style: const TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _primaryColor),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              '$category Specialists',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: _primaryColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No specialists found\nfor $category',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later as new experts join MindNova.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0)),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapistCard(BuildContext context, TherapistProfile t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    t.imageUrl ?? '',
                    width: 100, height: 100, fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(width: 100, height: 100, color: _primaryColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(t.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _secondaryColor)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${t.rating}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text(' (${t.experienceYrs} yrs exp)', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(t.bio, style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/therapist/profile', extra: t),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor.withValues(alpha: 0.1),
                  foregroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('View Profile', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
