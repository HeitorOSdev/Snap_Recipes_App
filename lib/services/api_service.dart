import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../model/recipe.dart';

class ApiService {
  // Configuração da API (Substitua por sua chave real se necessário)
  static const String _apiKey = 'AIzaSyCPIR2oDxvCeBlnrY4he7uaFXI58hIDFRk';
  static const String _model = 'gemini-2.5-flash-preview-09-2025';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  // Função utilitária para chamar a API com Backoff Exponencial
  Future<http.Response> _backoffFetch(
      String url, {
        Map<String, String>? headers,
        Object? body,
        int maxRetries = 3,
      }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode < 500 && response.statusCode != 429) {
          return response;
        }
      } catch (e) {
        // Log opcional ou tratamento silencioso para retry
      }

      if (attempt == maxRetries - 1) break;
      await Future.delayed(Duration(seconds: 1 << attempt));
    }
    throw Exception('Falha na conexão com a API após tentativas.');
  }

  Future<List<String>> identifyIngredients(XFile imageFile) async {
    if (_apiKey.isEmpty || _apiKey == '') {
       throw Exception('Chave de API não configurada.');
    }

    final bytes = await File(imageFile.path).readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = imageFile.mimeType ?? 'image/jpeg';

    const userPrompt = "Esta é uma foto de ingredientes de cozinha. Identifique todos os ingredientes comestíveis visíveis na imagem. Retorne apenas uma lista JSON no formato: {\"ingredients\": [\"nome_do_ingrediente_1\", \"nome_do_ingrediente_2\", ...]}";

    final payload = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": userPrompt},
            {
              "inlineData": {
                "mimeType": mimeType,
                "data": base64Image,
              },
            }
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "OBJECT",
          "properties": {
            "ingredients": {
              "type": "ARRAY",
              "items": {"type": "STRING"}
            }
          },
          "required": ["ingredients"]
        }
      }
    });

    final response = await _backoffFetch(
      '$_baseUrl?key=$_apiKey',
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    if (response.statusCode == 200) {
      final apiResponse = jsonDecode(response.body);
      final jsonText = apiResponse['candidates'][0]['content']['parts'][0]['text'];
      final parsedJson = jsonDecode(jsonText);

      return (parsedJson['ingredients'] as List<dynamic>)
          .map((item) => item.toString())
          .where((name) => name.isNotEmpty)
          .toList();
    } else {
      throw Exception('Falha na API: ${response.statusCode}');
    }
  }

  Future<List<Recipe>> fetchRecipes(List<String> ingredients) async {
    if (_apiKey.isEmpty || _apiKey == '') {
      throw Exception('Chave de API não encontrada.');
    }

    final ingredientsList = ingredients.join(', ');
    final userPrompt = "Gere 3 receitas criativas e deliciosas usando os seguintes ingredientes principais: $ingredientsList. Para cada receita, retorne o nome, uma descrição curta, os ingredientes utilizados e instruções simples. Formate a resposta como uma lista JSON.";

    final payload = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [{"text": userPrompt}]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "ARRAY",
          "items": {
            "type": "OBJECT",
            "properties": {
              "title": {"type": "STRING"},
              "description": {"type": "STRING"},
              "ingredientsUsed": {"type": "ARRAY", "items": {"type": "STRING"}},
              "instructions": {"type": "STRING"},
              "prepTimeMinutes": {"type": "INTEGER"},
            },
            "required": ["title", "description", "ingredientsUsed", "instructions", "prepTimeMinutes"]
          }
        }
      }
    });

    final response = await _backoffFetch(
      '$_baseUrl?key=$_apiKey',
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    if (response.statusCode == 200) {
      final apiResponse = jsonDecode(response.body);
      final jsonText = apiResponse['candidates'][0]['content']['parts'][0]['text'];
      final List<dynamic> parsedJson = jsonDecode(jsonText);

      return parsedJson.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Falha na API: ${response.statusCode}');
    }
  }
}
