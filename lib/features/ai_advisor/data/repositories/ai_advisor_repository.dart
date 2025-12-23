import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/constants/app_constants.dart';

class AiAdvisorRepository {
  late final GenerativeModel _model;

  String apiKey = dotenv.env['API_KEY'] ?? '';
  AiAdvisorRepository() {
    _model = GenerativeModel(model: AppConstants.geminiModel, apiKey: apiKey);
  }

  Future<String> getAiAdvice(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'No response from AI';
    } catch (e) {
      return 'Error connecting to AI: ${e.toString()}';
    }
  }
}
