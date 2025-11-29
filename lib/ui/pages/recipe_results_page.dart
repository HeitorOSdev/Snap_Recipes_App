import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../../model/recipe.dart';
import '../../main.dart';
// Para as cores e função de backoff

// --- Configuração da API ---
// ATENÇÃO: COLOQUE SUA CHAVE DA API GEMINI AQUI para que a busca de receitas funcione.
const String _geminiApiKey = 'AIzaSyDEphoPAFuvb7StLLhxUaz9O3yd_3ly8Fg';
const String _geminiModel = 'gemini-2.5-flash-preview-09-2025';

class RecipeResultsPage extends StatefulWidget {
  final List<String> ingredients;
  final bool isDarkMode;

  const RecipeResultsPage({
    super.key,
    required this.ingredients,
    required this.isDarkMode,
  });

  @override
  State<RecipeResultsPage> createState() => _RecipeResultsPageState();
}

class _RecipeResultsPageState extends State<RecipeResultsPage> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inicia a busca de receitas assim que a tela é carregada
    _fetchRecipes();
  }

  // Função utilitária para chamar a API com Backoff Exponencial (copiada de main.dart)
  Future<http.Response> _backoffFetch(
      String url, {
        Map<String, String>? headers,
        Object? body,
        int maxRetries = 5,
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
        // Ignora erros de rede e timeout, tenta novamente
      }

      if (attempt == maxRetries - 1) break;

      final delay = Duration(seconds: 1 << attempt);
      await Future.delayed(delay);
    }
    throw Exception('Falha ao se conectar com a API após $maxRetries tentativas.');
  }

  // Função para gerar receitas usando a API Gemini
  Future<void> _fetchRecipes() async {
    // Verifica se a chave foi configurada.
    if (_geminiApiKey.isEmpty || _geminiApiKey == 'SUA_CHAVE_AQUI') {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ERRO: Por favor, insira sua chave da API Gemini na constante _geminiApiKey para buscar as receitas.';
      });
      return;
    }

    final ingredientsList = widget.ingredients.join(', ');

    // 1. Prompt do Usuário e Estrutura JSON Desejada
    final userPrompt = "Gere 3 receitas criativas e deliciosas usando os seguintes ingredientes principais: $ingredientsList. Para cada receita, retorne o nome, uma descrição curta, os ingredientes utilizados e instruções simples. Formate a resposta como uma lista JSON.";

    final payload = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": userPrompt}
          ]
        }
      ],
      "generationConfig": { // O campo correto é generationConfig
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "ARRAY",
          "items": {
            "type": "OBJECT",
            "properties": {
              "title": {"type": "STRING", "description": "Nome da receita"},
              "description": {"type": "STRING", "description": "Descrição breve"},
              "ingredientsUsed": {"type": "ARRAY", "items": {"type": "STRING"}, "description": "Lista de ingredientes utilizados"},
              "instructions": {"type": "STRING", "description": "Instruções passo a passo"},
              "prepTimeMinutes": {"type": "INTEGER", "description": "Tempo de preparo em minutos"},
            },
            "required": ["title", "description", "ingredientsUsed", "instructions", "prepTimeMinutes"]
          }
        }
      }
    });

    // 2. Chamar a API
    final apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$_geminiApiKey';

    try {
      final response = await _backoffFetch(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      // 3. Processar a Resposta
      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        final jsonText = apiResponse['candidates'][0]['content']['parts'][0]['text'];
        final List<dynamic> parsedJson = jsonDecode(jsonText);

        setState(() {
          _recipes = parsedJson.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
          _isLoading = false;
        });

      } else {
        // Logar o corpo da resposta em caso de falha na API
        throw Exception('Falha na API: ${response.statusCode}. Corpo: ${response.body}');
      }
    } catch (e) {
      print('Erro ao gerar receitas: $e');
      setState(() {
        _errorMessage = 'Falha ao buscar receitas. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  // --- Widgets de UI ---

  Color getTextColor() => widget.isDarkMode ? textDark : textLight;
  Color getSubtleBgColor() => widget.isDarkMode ? subtleDark : subtleLight;
  Color getBorderColor() => widget.isDarkMode ? borderDark : borderLight;

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text('Gerando receitas criativas...', style: TextStyle(color: getTextColor())),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade400, fontSize: 16)),
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Nenhuma receita encontrada para os ingredientes fornecidos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: getTextColor().withOpacity(0.7), fontSize: 16),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Receitas com ${widget.ingredients.join(', ')}',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: getTextColor()
            ),
          ),
        ),
        // Mapeia e exibe os cards de receita
        ..._recipes.map((recipe) => RecipeCard(
          recipe: recipe,
          isDarkMode: widget.isDarkMode,
          getTextColor: getTextColor,
          getBorderColor: getBorderColor,
        )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados da Receita', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.isDarkMode ? backgroundDark : backgroundLight,
        iconTheme: IconThemeData(color: getTextColor()),
        titleTextStyle: TextStyle(color: getTextColor(), fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }
}

// Card para exibir uma única receita
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isDarkMode;
  final Color Function() getTextColor;
  final Color Function() getBorderColor;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isDarkMode,
    required this.getTextColor,
    required this.getBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDarkMode ? subtleDark : subtleLight,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: getBorderColor()),
        boxShadow: [
          BoxShadow(
            color: getBorderColor().withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                '${recipe.prepTimeMinutes} min de preparo',
                style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            recipe.description,
            style: TextStyle(color: getTextColor().withOpacity(0.8), fontSize: 16),
          ),
          const SizedBox(height: 16),

          Text(
            'Ingredientes Chave:',
            style: TextStyle(color: getTextColor(), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: recipe.ingredientsUsed.map((ing) => Chip(
              label: Text(ing, style: TextStyle(color: primaryColor)),
              backgroundColor: primaryColor.withOpacity(0.1),
              side: const BorderSide(color: primaryColor),
            )).toList(),
          ),

          const SizedBox(height: 16),
          Text(
            'Instruções:',
            style: TextStyle(color: getTextColor(), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            recipe.instructions,
            style: TextStyle(color: getTextColor().withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}