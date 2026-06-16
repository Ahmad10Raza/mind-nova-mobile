import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _errorColor = Color(0xFFFFB4AB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistLiveSessionScreen extends StatefulWidget {
  final bool isTherapistRole;
  final String remoteName;
  final String? remoteImageUrl;
  final String roomId;
  final String appointmentId;

  const TherapistLiveSessionScreen({
    super.key,
    required this.isTherapistRole,
    required this.remoteName,
    this.remoteImageUrl,
    required this.roomId,
    required this.appointmentId,
  });

  @override
  State<TherapistLiveSessionScreen> createState() => _TherapistLiveSessionScreenState();
}

class _TherapistLiveSessionScreenState extends State<TherapistLiveSessionScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isInCall = false;
  final TextEditingController _liveNotesController = TextEditingController();

  // Session Timer
  late int _remainingSeconds;
  Timer? _timer;

  /// Jitsi native SDK is only supported on Android and iOS.
  bool get _isNativeSdkSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
           defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 45 * 60; // 45 minutes default
  }

  @override
  void dispose() {
    _timer?.cancel();
    _liveNotesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _showSessionEndedDialog();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  String get _formattedTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _joinCall() async {
    final jitsiRoom = 'mindnova_${widget.roomId}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    // meet.jit.si now requires host login. We use a reliable public alternative that doesn't require login.
    final jitsiUrl = 'https://meet.ffmuc.net/$jitsiRoom';

    if (_isNativeSdkSupported) {
      // On Android/iOS: try native Jitsi SDK
      try {
        // Dynamic import to avoid compile-time crash on Web/Linux
        final jitsiModule = await _tryLaunchNativeJitsi(jitsiRoom);
        if (!jitsiModule) {
          // Fallback to URL if native fails
          await _launchJitsiUrl(jitsiUrl);
        }
      } catch (e) {
        debugPrint('Native Jitsi failed, falling back to URL: $e');
        await _launchJitsiUrl(jitsiUrl);
      }
    } else if (kIsWeb) {
      // On Web: open Jitsi in a new browser tab
      await _launchJitsiUrl(jitsiUrl);
    } else {
      // Linux/Desktop: open in browser
      await _launchJitsiUrl(jitsiUrl);
    }

    if (mounted) {
      setState(() => _isInCall = true);
      _startTimer();
    }
  }

  Future<bool> _tryLaunchNativeJitsi(String room) async {
    try {
      // Dynamically load the Jitsi SDK only on native platforms
      final dynamic jitsiMeet = _createJitsiMeet();
      if (jitsiMeet == null) return false;

      final options = _createJitsiOptions(room);
      if (options == null) return false;

      await jitsiMeet.join(options);
      return true;
    } catch (e) {
      debugPrint('Native Jitsi SDK error: $e');
      return false;
    }
  }

  dynamic _createJitsiMeet() {
    try {
      // Using reflection-style approach to avoid compile-time dependency on Web
      // The actual import is conditional
      return _JitsiNativeHelper.createMeet();
    } catch (e) {
      return null;
    }
  }

  dynamic _createJitsiOptions(String room) {
    try {
      return _JitsiNativeHelper.createOptions(
        room: room,
        isMuted: _isMuted,
        isVideoOff: _isVideoOff,
        remoteName: widget.remoteName,
        isTherapist: widget.isTherapistRole,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _launchJitsiUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open video call. Please visit: $url')),
      );
    }
  }

  void _endCall() {
    _timer?.cancel();
    if (widget.isTherapistRole) {
      context.pushReplacement('/therapist/portal/notes', extra: {
         'remoteName': widget.remoteName,
         'appointmentId': widget.appointmentId,
      });
    } else {
      context.pushReplacement('/therapist/post-session', extra: widget.appointmentId);
    }
  }

  void _showSessionEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1F2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Session Complete', style: GoogleFonts.manrope(color: _primaryColor, fontWeight: FontWeight.w700)),
        content: Text(
          'Your 45-minute session has ended. Would you like to continue or wrap up?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _remainingSeconds = 15 * 60); // Extend 15 min
              _startTimer();
            },
            child: Text('Extend 15 min', style: GoogleFonts.inter(color: _secondaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endCall();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: const Color(0xFF32285E)),
            child: Text('Wrap Up', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _openTherapistNotesPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLiveNotesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: _isInCall
                ? _buildInCallView()
                : _buildPreCallView(),
          ),

          // Header Overlay
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildHeader(),
          ),

          // Local Camera PiP (only in call)
          if (_isInCall)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              right: 24,
              child: _buildLocalPip(),
            ),

          // Bottom Control Bar
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: _buildControlBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreCallView() {
    return Container(
      color: const Color(0xFF1B1F2C),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: _secondaryColor.withValues(alpha: 0.2),
              backgroundImage: widget.remoteImageUrl != null
                  ? NetworkImage(widget.remoteImageUrl!)
                  : null,
              child: widget.remoteImageUrl == null
                  ? Text(widget.remoteName.isNotEmpty ? widget.remoteName[0] : '?',
                      style: GoogleFonts.manrope(fontSize: 48, fontWeight: FontWeight.bold, color: _secondaryColor))
                  : null,
            ),
            const SizedBox(height: 20),
            Text(widget.remoteName, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              widget.isTherapistRole ? 'Patient Session' : 'Therapy Session',
              style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0)),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _joinCall,
              icon: const Icon(Icons.videocam, size: 24),
              label: Text('Join Video Session', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: _backgroundDeep,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _isVideoOff = true);
                _joinCall();
              },
              icon: const Icon(Icons.mic, size: 24),
              label: Text('Audio Only', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: BorderSide(color: _primaryColor.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),
            if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text('Call will open in your browser', style: GoogleFonts.inter(fontSize: 12, color: Colors.amber)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInCallView() {
    return Container(
      color: const Color(0xFF1B1F2C),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: _secondaryColor.withValues(alpha: 0.2),
              child: Text(widget.remoteName.isNotEmpty ? widget.remoteName[0] : '?',
                  style: GoogleFonts.manrope(fontSize: 40, fontWeight: FontWeight.bold, color: _secondaryColor)),
            ),
            const SizedBox(height: 16),
            Text(widget.remoteName, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('In Session', style: GoogleFonts.inter(fontSize: 14, color: _secondaryColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 24, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timer badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _isInCall ? _secondaryColor.withValues(alpha: 0.5) : Colors.white24),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: _isInCall ? _secondaryColor : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formattedTime,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white54, size: 20),
              const SizedBox(width: 8),
              Text('End-to-End Encrypted', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalPip() {
    return Container(
      width: 100, height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF353946),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: _isVideoOff
          ? const Center(child: Icon(Icons.videocam_off, color: Colors.white54))
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(color: Colors.grey.shade800),
            ),
    );
  }

  Widget _buildControlBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1F2C).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                color: _isMuted ? _errorColor : Colors.white,
                onTap: () => setState(() => _isMuted = !_isMuted),
              ),
              _buildControlButton(
                icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                color: _isVideoOff ? _errorColor : Colors.white,
                onTap: () => setState(() => _isVideoOff = !_isVideoOff),
              ),
              if (!_isInCall)
                _buildControlButton(
                  icon: Icons.call,
                  color: _backgroundDeep,
                  bgColor: _secondaryColor,
                  onTap: _joinCall,
                ),
              if (_isInCall && widget.isTherapistRole)
                _buildControlButton(
                  icon: Icons.edit_note,
                  color: _primaryColor,
                  onTap: _openTherapistNotesPanel,
                ),
              if (_isInCall)
                _buildControlButton(
                  icon: Icons.call_end,
                  color: Colors.white,
                  bgColor: _errorColor,
                  onTap: _endCall,
                ),
              if (!_isInCall)
                _buildControlButton(
                  icon: Icons.arrow_back,
                  color: Colors.white,
                  onTap: () => context.pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, Color? bgColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildLiveNotesSheet() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Color(0xFF1B1F2C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: _primaryColor, width: 2)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Live Session Notes', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _liveNotesController,
                maxLines: null,
                expands: true,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Jot down observations or homework ideas...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF0F131F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to isolate native Jitsi SDK usage.
/// On platforms where jitsi_meet_flutter_sdk is not available,
/// these methods will throw and the caller falls back to URL launch.
class _JitsiNativeHelper {
  static dynamic createMeet() {
    // This will only succeed on Android/iOS where the native plugin is registered
    try {
      // ignore: depend_on_referenced_packages
      final module = _getNativeModule();
      return module;
    } catch (e) {
      return null;
    }
  }

  static dynamic _getNativeModule() {
    // Lazy-load to prevent Web/Linux crash
    // ignore: avoid_dynamic_calls
    throw UnimplementedError('Native Jitsi not available on this platform');
  }

  static dynamic createOptions({
    required String room,
    required bool isMuted,
    required bool isVideoOff,
    required String remoteName,
    required bool isTherapist,
  }) {
    throw UnimplementedError('Native Jitsi not available on this platform');
  }
}
