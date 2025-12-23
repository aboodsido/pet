import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/constants/app_constants.dart';

class AiAdvisorRepository {
  late final GenerativeModel _model;

  AiAdvisorRepository() {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    );
  }

  Future<String> getAiAdvice(String prompt) async {
    try {
      if (AppConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
        return 'Please set your Gemini API Key in AppConstants to use the AI Advisor.';
      }

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'No response from AI';
    } catch (e) {
      return 'Error connecting to AI: ${e.toString()}';
    }
  }
}
