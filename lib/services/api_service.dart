import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String authUrl = 'http://localhost:8000';
  static const String cardsUrl = 'http://localhost:8001';
  static const String aiUrl = 'http://localhost:8002';
  static const String progressUrl = 'http://localhost:8003';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$authUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access_token']);
      return true;
    }
    return false;
  }

  static Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$authUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getCards() async {
    final headers = await authHeaders();
    final response = await http.get(
      Uri.parse('$cardsUrl/cards/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> createCard(
      String word, String translation, String language, String? example) async {
    final headers = await authHeaders();
    final response = await http.post(
      Uri.parse('$cardsUrl/cards/'),
      headers: headers,
      body: jsonEncode({
        'word': word,
        'translation': translation,
        'language': language,
        'example': example,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> generateWordInfo(
      String word, String language) async {
    final headers = await authHeaders();
    final response = await http.post(
      Uri.parse('$aiUrl/ai/generate'),
      headers: headers,
      body: jsonEncode({'word': word, 'language': language}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getStats() async {
    final headers = await authHeaders();
    final response = await http.get(
      Uri.parse('$progressUrl/progress/stats'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> submitReview(int cardId, bool correct) async {
    final headers = await authHeaders();
    final response = await http.post(
      Uri.parse('$progressUrl/progress/review'),
      headers: headers,
      body: jsonEncode({'card_id': cardId, 'correct': correct}),
    );
    return response.statusCode == 201;
  }

  static Future<bool> deleteCard(int id) async {
    final headers = await authHeaders();
    final response = await http.delete(
      Uri.parse('$cardsUrl/cards/$id'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  static Future<void> resetAll(List<int> cardIds) async {
    for (final id in cardIds) {
      await deleteCard(id);
    }
  }

  static Future<Map<String, dynamic>?> generateGameWord(
      String sourceLang, List<String> usedWords) async {
    final headers = await authHeaders();
    final response = await http.post(
      Uri.parse('$aiUrl/ai/word'),
      headers: headers,
      body: jsonEncode({'source_lang': sourceLang, 'used_words': usedWords}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<Map<String, dynamic>?> validateAnswer(String word,
      String sourceLang, String targetLang, String userAnswer) async {
    final headers = await authHeaders();
    final response = await http.post(
      Uri.parse('$aiUrl/ai/validate'),
      headers: headers,
      body: jsonEncode({
        'word': word,
        'source_lang': sourceLang,
        'target_lang': targetLang,
        'user_answer': userAnswer,
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<bool> resetProgress() async {
    final headers = await authHeaders();
    final response = await http.delete(
      Uri.parse('$progressUrl/progress/reset'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  static Future<bool> resetCards() async {
    final headers = await authHeaders();
    final response = await http.delete(
      Uri.parse('$cardsUrl/cards/reset'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> generateQuiz(
      String word, String language, String translation) async {
    final headers = await authHeaders();
    final response = await http.post(
      Uri.parse('$aiUrl/ai/quiz'),
      headers: headers,
      body: jsonEncode(
          {'word': word, 'language': language, 'translation': translation}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }
}
