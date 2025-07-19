import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class ElevenLabsService {
  static const String apiKey = 'sk_30bbc5db8c29cf473ccc0b01df116b662b7b5aacfd09f65a';
  static const String voiceId = 'EXAVITQu4vr4xnSDxMaL'; // Change to your chosen voice

  static Future<void> speakText(String text) async {
    final url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceId';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {
          "stability": 0.4,
          "similarity_boost": 0.75
        }
      }),
    );

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/speech.mp3');
      await file.writeAsBytes(response.bodyBytes);

      final player = AudioPlayer();
      await player.setFilePath(file.path);
      await player.play();
    } else {
      print("TTS failed: ${response.body}");
    }
  }
}
