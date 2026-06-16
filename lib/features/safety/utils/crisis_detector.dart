import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Utility class for local, non-intrusive crisis detection during text input.
class CrisisDetector {
  static final CrisisDetector _instance = CrisisDetector._internal();
  factory CrisisDetector() => _instance;
  CrisisDetector._internal();

  Timer? _debounce;
  
  // Layer 1: Robust Regex covering explicit keywords and typological variations.
  final RegExp _crisisRegex = RegExp(
    r'\b(want to die|wanna die|kill myself|end my life|self harm|suicide|suicidal|no reason to live)\b',
    caseSensitive: false,
  );

  // Layer 2 Mild keywords, only trigger if user is in a distressed state.
  final RegExp _mildRegex = RegExp(
    r"\b(hopeless|give up|can't take it anymore|meaningless)\b",
    caseSensitive: false,
  );

  bool _bannerShowing = false;

  /// Analyze text input with a 500ms debounce.
  /// Set [hasRecentDistress] based on the user's recent mood logs or AI sentiment.
  void analyzeText(BuildContext context, String text, {bool hasRecentDistress = false}) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _evaluate(context, text, hasRecentDistress);
    });
  }

  void _evaluate(BuildContext context, String text, bool hasRecentDistress) {
    if (_bannerShowing) return; // Prevent spamming

    bool hasKeyword = _crisisRegex.hasMatch(text);
    bool hasMildKeyword = _mildRegex.hasMatch(text);
    
    // Hybrid logic: Explicit regex OR (recent distress + mild keywords)
    if (hasKeyword || (hasRecentDistress && hasMildKeyword)) {
      showSupportBanner(context);
    }
  }

  /// Displays a soft, non-intrusive support banner at the top of the screen.
  void showSupportBanner(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    
    _bannerShowing = true;

    final banner = MaterialBanner(
      content: const Text(
        "You're not alone. Tap here for support tools 💜",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      leading: const Icon(Icons.favorite, color: Colors.white),
      backgroundColor: Colors.indigo.shade900,
      actions: [
        TextButton(
          onPressed: () {
            messenger.clearMaterialBanners();
            _bannerShowing = false;
          },
          child: const Text('DISMISS', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: () {
            messenger.clearMaterialBanners();
            _bannerShowing = false;
            // Record anonymous analytics here later
            context.push('/crisis');
          },
          child: const Text('GET HELP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );

    messenger.showMaterialBanner(banner);

    // Auto-dismiss after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (_bannerShowing) {
        messenger.clearMaterialBanners();
        _bannerShowing = false;
      }
    });
  }
}
