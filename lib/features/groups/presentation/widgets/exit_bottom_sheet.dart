import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExitBottomSheet extends StatefulWidget {
  final Function(String) onConfirm;

  const ExitBottomSheet({super.key, required this.onConfirm});

  @override
  State<ExitBottomSheet> createState() => _ExitBottomSheetState();
}

class _ExitBottomSheetState extends State<ExitBottomSheet> {
  String? _selectedReason;

  final List<String> _reasons = [
    'I don\'t feel comfortable here',
    'The group is too quiet',
    'I found a better group',
    'I want to try a different category',
    'I achieved my goals',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Leaving the Circle?',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your progress and check-ins will be archived. We\'d love to know why you\'re leaving to help us improve.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white38,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ..._reasons.map((reason) => _buildReasonTile(reason)).toList(),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'STAY',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _selectedReason == null 
                    ? null 
                    : () => widget.onConfirm(_selectedReason!),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: _selectedReason == null 
                        ? Colors.white10 
                        : const Color(0xFFEF5350),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'LEAVE CIRCLE',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _selectedReason == null 
                            ? Colors.white10 
                            : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildReasonTile(String reason) {
    final isSelected = _selectedReason == reason;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFEF5350).withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFFEF5350), size: 20),
          ],
        ),
      ),
    );
  }
}
