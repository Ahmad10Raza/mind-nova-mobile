import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/gratitude_provider.dart';

class GratitudeMemoryVaultScreen extends ConsumerWidget {
  const GratitudeMemoryVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultAsync = ref.watch(gratitudeMemoryVaultProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        title: Text(
          'Memory Vault',
          style: GoogleFonts.inter(
            color: const Color(0xFF2D3748),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: vaultAsync.when(
        data: (memories) {
          if (memories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No memories saved yet.',
                    style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFA0AEC0)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pin entries or add photos to build your vault.',
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFA0AEC0)),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: memory.type == 'PHOTO' && memory.mediaUrl != null
                            ? Image.network(
                                memory.mediaUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFF3E8FF),
                                  child: Icon(
                                    memory.type == 'VOICE' ? Icons.mic : Icons.image_not_supported_rounded,
                                    color: const Color(0xFF805AD5),
                                    size: 40,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFF3E8FF),
                                child: Icon(
                                  memory.type == 'VOICE' ? Icons.mic : Icons.bookmark_added_rounded,
                                  color: const Color(0xFF805AD5),
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              memory.emotionalLabel ?? 'Special Moment',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              '${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFFA0AEC0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load memory vault.')),
      ),
    );
  }
}
