import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

// Conditional import: use real dart:io File on native, a no-op on Web
import 'voice_service_io.dart'
    if (dart.library.html) 'voice_service_web.dart' as platform;

class VoiceEntryResult {
  final String voiceEntryId;
  final String? audioUrl;
  final String? originalLanguage;
  final String transcript;
  final String? translatedEnglish;

  VoiceEntryResult({
    required this.voiceEntryId,
    this.audioUrl,
    this.originalLanguage,
    required this.transcript,
    this.translatedEnglish,
  });

  factory VoiceEntryResult.fromJson(Map<String, dynamic> json) {
    return VoiceEntryResult(
      voiceEntryId: json['voiceEntryId'] ?? '',
      audioUrl: json['audioUrl'],
      originalLanguage: json['originalLanguage'],
      transcript: json['originalTranscript'] ?? json['transcript'] ?? '',
      translatedEnglish: json['translatedEnglish'],
    );
  }
}

class VoiceService {
  final ApiClient _apiClient;

  VoiceService(this._apiClient);

  Future<VoiceEntryResult> transcribeAudio({
    required String filePath,
    required String featureType,
    required bool keepRecording,
  }) async {
    MultipartFile multipartFile;

    try {
      debugPrint('VoiceService: Reading audio from $filePath');
      final Uint8List bytes = await platform.readFileBytes(filePath);
      
      // Determine filename based on platform
      final filename = kIsWeb ? 'voice_recording.webm' : filePath.split('/').last;
      
      debugPrint('VoiceService: Got ${bytes.length} bytes, filename: $filename');

      multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: filename,
      );
    } catch (e) {
      debugPrint('VoiceService: Error reading audio: $e');
      throw Exception('Failed to read audio file: $e');
    }

    FormData formData = FormData.fromMap({
      "file": multipartFile,
      "featureType": featureType,
      "keepRecording": keepRecording.toString(),
    });

    final response = await _apiClient.post(
      '/voice/transcribe',
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return VoiceEntryResult.fromJson(response.data);
    } else {
      throw Exception('Failed to transcribe audio: ${response.statusCode}');
    }
  }
}

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VoiceService(apiClient);
});
