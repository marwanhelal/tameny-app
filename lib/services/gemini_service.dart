import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final instance = GeminiService._();

  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyBFWTIbtEUKNQ32rtiQ_jCARTuRrNN732Y',
  );

  GeminiService._();

  Future<String> sendMessage(String prompt, {File? imageFile}) async {
    final content = [
      Content.text('''
You are Tameny, the chatbot of the Tameny app — a digital healthcare platform that connects patients with hospitals, clinics, and labs in one place. Help users navigate the app, book doctors, search reservations, and answer healthcare-related queries.
'''),
      Content.text(prompt),
    ];

    if (imageFile != null) {
      content.add(
        Content.multi([DataPart('image/jpeg', await imageFile.readAsBytes())]),
      );
    }

    try {
      final response = await model.generateContent(content);

      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        final parts = candidate.content.parts;

        final textPart = parts.whereType<TextPart>().firstOrNull;

        return textPart?.text ?? 'Sorry, no reply generated.';
      }

      return 'Sorry, no candidates generated.';
    } catch (e) {
      return '❌ Error: $e';
    }
  }
}
