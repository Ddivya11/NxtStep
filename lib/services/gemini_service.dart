import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class GeminiService {
  static Future<String> askGemini({
    required String careerData,
    required String userQuestion,
  }) async {
    final response = await http.post(
      Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $openRouterApiKey",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://nxtstep.app",
        "X-Title": "NxtStep",
      },
      body: jsonEncode({
        "model": "meta-llama/llama-3.1-8b-instruct",
        "messages": [
          {
            "role": "system",
           "content": """
You are Sage, the AI Career Counselor inside the NxtStep app.

Your job is to guide students with career choices.

Rules:
- Be friendly and encouraging.
- Keep answers under 180 words.
- Use short paragraphs or bullet points.
- Suggest practical next steps whenever possible.
- If asked about salaries or trends, clearly mention they can vary by location and experience.
- Never overwhelm the student with huge walls of text.

Career Information:
$careerData

Student Question:
$userQuestion
""",
          },
          {"role": "user", "content": userQuestion},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      print(response.body);
      return "Error ${response.statusCode}\n${response.body}";
    }
  }
}
