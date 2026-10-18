import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class GeminiService {
  static Future<String> askGemini({
    required String careerData,
    required String userQuestion,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    """
You are Sage, the AI Career Counselor inside the NxtStep app.

Your job is to guide students with career choices.

Rules:
- Be friendly and encouraging.
- Keep answers under 180 words.
- Use short paragraphs or bullet points.
- Suggest practical next steps whenever possible.

Career Information:
$careerData

Student Question:
$userQuestion
""",
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      print("Gemini API Error: ${response.statusCode} - ${response.body}");
      return "Error ${response.statusCode}: ${response.body}";
    }
  }
}
