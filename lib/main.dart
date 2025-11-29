import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:snaprecipes/ui/pages/recipe_results_page.dart';
import 'package:snaprecipes/ui/widgets/headlineSection.dart';
import 'package:snaprecipes/ui/widgets/ingredientChip.dart';


// --- Configuração da API (Substitua por sua chave real) ---
// Em um projeto real, esta chave deve ser armazenada de forma segura (e.g., variáveis de ambiente)
const String _geminiApiKey = 'AIzaSyDEphoPAFuvb7StLLhxUaz9O3yd_3ly8Fg';
const String _geminiModel = 'gemini-2.5-flash-preview-09-2025';

// Note: Em um projeto real, você usaria um tema (ThemeData) para isso.
// Cores (Mapeamento direto dos valores hex do Tailwind)
const Color primaryColor = Color(0xFF46ec13);
const Color backgroundLight = Color(0xFFf6f8f6);
const Color backgroundDark = Color(0xFF142210);
const Color textLight = Color(0xFF111b0d);
const Color textDark = Color(0xFFe8f5e9);
const Color subtleLight = Color(0xFFeef3ed);
const Color subtleDark = Color(0xFF21361c);
const Color borderLight = Color(0xFFdce5d9);
const Color borderDark = Color(0xFF304d2a);
// Fonte (Simulação da Plus Jakarta Sans, usando a fonte padrão do Flutter)
const String fontDisplay = 'Plus Jakarta Sans';

// --------------------------------------------------------------------

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuração do Tema Básico para simular o Dark/Light Mode
    return MaterialApp(
      title: 'RecipeApp - Ingredient Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: fontDisplay,
        scaffoldBackgroundColor: backgroundLight,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textLight),
          titleLarge: TextStyle(color: textLight),
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          background: backgroundLight,
          surface: backgroundLight, // Surface para elementos como dialogs
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: fontDisplay,
        scaffoldBackgroundColor: backgroundDark,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textDark),
          titleLarge: TextStyle(color: textDark),
        ),
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          background: backgroundDark,
          surface: backgroundDark, // Surface para elementos como dialogs
        ),
        useMaterial3: true,
      ),
      home: const MainPage(isDarkMode: false),
    );
  }
}

// --------------------------------------------------------------------
// MainPage agora é um StatefulWidget para gerenciar o estado da câmera e da IA
// --------------------------------------------------------------------
class MainPage extends StatefulWidget {
  final bool isDarkMode;
  const MainPage({super.key, required this.isDarkMode});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Estado para a Imagem capturada
  XFile? _pickedImage;
  // Estado para a lista de Ingredientes (inicializada com simulação)
  List<String> _identifiedIngredients = ['Tomate', 'Cebola', 'Manjericão'];
  // Estado de Carregamento para a Análise de IA
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // --- Funções de API e Câmera ---

  // Função utilitária para chamar a API com Backoff Exponencial
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

        print('Tentativa ${attempt + 1} falhou com status ${response.statusCode}. Retrying...');

      } catch (e) {
        print('Tentativa ${attempt + 1} falhou com erro: $e. Retrying...');
      }

      if (attempt == maxRetries - 1) break;

      final delay = Duration(seconds: 1 << attempt);
      await Future.delayed(delay);
    }
    throw Exception('Falha ao se conectar com a API após $maxRetries tentativas.');
  }

  // Função principal para analisar a imagem e extrair ingredientes com a IA
  Future<void> _analyzeImageForIngredients(XFile imageFile) async {
    // Verifica se a chave foi configurada.
    if (_geminiApiKey.isEmpty || _geminiApiKey == 'SUA_CHAVE_AQUI') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ERRO: Por favor, insira sua chave da API Gemini em _geminiApiKey.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Converter a imagem para Base64
      final bytes = await File(imageFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = imageFile.mimeType ?? 'image/jpeg';

      // 2. Montar o Payload da API (Solicitando JSON estruturado)
      final userPrompt = "Esta é uma foto de ingredientes de cozinha. Identifique todos os ingredientes comestíveis visíveis na imagem. Retorne apenas uma lista JSON no formato: {\"ingredients\": [\"nome_do_ingrediente_1\", \"nome_do_ingrediente_2\", ...]}";

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
        "generationConfig": { // <-- CORREÇÃO: Usa generationConfig
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

      // 3. Chamar a API
      final apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$_geminiApiKey';

      final response = await _backoffFetch(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      // 4. Processar a Resposta
      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        final jsonText = apiResponse['candidates'][0]['content']['parts'][0]['text'];
        final parsedJson = jsonDecode(jsonText);

        final newIngredients = (parsedJson['ingredients'] as List<dynamic>)
            .map((item) => item.toString())
            .where((name) => name.isNotEmpty)
            .toList();

        if (newIngredients.isNotEmpty) {
          setState(() {
            // Adiciona novos ingredientes, evitando duplicatas.
            for (var ing in newIngredients) {
              if (!_identifiedIngredients.contains(ing)) {
                _identifiedIngredients.add(ing);
              }
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sucesso! Ingredientes identificados: ${newIngredients.join(', ')}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A IA não identificou ingredientes na imagem. Tente novamente.')),
          );
        }

      } else {
        // Logar o corpo da resposta em caso de falha na API
        throw Exception('Falha na API: ${response.statusCode}. Corpo: ${response.body}');
      }
    } catch (e) {
      print('Erro na análise de IA: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao analisar a imagem. Verifique o console.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para abrir a câmera, capturar e iniciar a análise
  Future<void> _openCamera() async {
    if (_isLoading) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
        });

        // Inicia a análise da imagem
        await _analyzeImageForIngredients(image);
      }
    } catch (e) {
      print('Erro ao abrir a câmera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao acessar a câmera: $e. Verifique as permissões.')),
      );
    }
  }

  // Função para remover ingrediente
  void _removeIngredient(String ingredient) {
    setState(() {
      _identifiedIngredients.remove(ingredient);
    });
  }

  // Função para adicionar ingrediente manualmente (NOVA)
  void _addManualIngredient(String ingredient) {
    final capitalized = ingredient.trim().isNotEmpty
        ? ingredient.trim()[0].toUpperCase() + ingredient.trim().substring(1).toLowerCase()
        : '';

    if (capitalized.isNotEmpty && !_identifiedIngredients.contains(capitalized)) {
      setState(() {
        _identifiedIngredients.add(capitalized);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrediente "$capitalized" adicionado!')),
      );
    }
  }

  // Função para exibir o modal de adição manual (NOVA)
  void _showAddManualIngredientDialog() {
    String newIngredient = '';
    final isCurrentDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: isCurrentDarkMode ? backgroundDark : backgroundLight,
          title: Text(
              'Adicionar Ingrediente',
              style: TextStyle(color: getTextColor(), fontWeight: FontWeight.bold)
          ),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ex: Batata, Cenoura...',
              hintStyle: TextStyle(color: getTextColor().withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: getBorderColor()),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
            style: TextStyle(color: getTextColor()),
            onChanged: (value) {
              newIngredient = value;
            },
            onSubmitted: (value) {
              _addManualIngredient(value);
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: getTextColor().withOpacity(0.7))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                _addManualIngredient(newIngredient);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: textLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  // Função para buscar receitas (ATUALIZADA)
  void _searchRecipes() {
    if (_identifiedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um ingrediente para buscar receitas!')),
      );
      return;
    }

    // NAVEGAÇÃO PARA A TELA DE RESULTADOS
    final isCurrentDarkMode = Theme.of(context).brightness == Brightness.dark;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeResultsPage(
          ingredients: _identifiedIngredients,
          isDarkMode: isCurrentDarkMode,
        ),
      ),
    );
  }


  // --- Widgets de Construção da UI (usando as novas funções de estado) ---

  // Função auxiliar para obter a cor correta baseada no modo
  Color getTextColor() => Theme.of(context).brightness == Brightness.dark ? textDark : textLight;
  Color getSubtleBgColor() => Theme.of(context).brightness == Brightness.dark ? subtleDark : subtleLight;
  Color getBorderColor() => Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;

  @override
  Widget build(BuildContext context) {
    // Tenta usar o brilho do tema se o widget.isDarkMode for false
    final isCurrentDarkMode = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(isDarkMode: isCurrentDarkMode), // Usando o tema atual

      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    HeadlineSection(isDarkMode: isCurrentDarkMode),

                    _buildCameraButton(),

                    _buildIngredientsSection(isCurrentDarkMode),
                  ],
                ),
              ),
            ),
          ),
          _buildFooterButton(isCurrentDarkMode),
        ],
      ),
    );
  }

  // 3. Camera Button (Atualizado para chamar a função de câmera e mostrar o loading)
  Widget _buildCameraButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Container(
        width: 192,
        height: 192,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          child: InkWell(
            onTap: _isLoading ? null : _openCamera, // Desabilita durante o carregamento
            borderRadius: BorderRadius.circular(9999),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: textLight) // Indicador de carregamento
                  : Icon(
                _pickedImage == null ? Icons.photo_camera : Icons.check_circle_outline,
                color: textLight,
                size: 80,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 4. Ingredients Section (Atualizado para usar o estado real)
  Widget _buildIngredientsSection(bool isCurrentDarkMode) {
    final Color subtleBgColor = getSubtleBgColor();
    final Color borderColor = getBorderColor();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Ingredientes Identificados',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Ingredient Chips Container
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: subtleBgColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor),
            ),
            child: _identifiedIngredients.isNotEmpty
                ? Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: _identifiedIngredients.map((name) => IngredientChip(
                name: name,
                isDarkMode: isCurrentDarkMode, // Passa o modo atual
                onRemove: () => _removeIngredient(name), // Usa a função de remoção
              )).toList(),
            )
                : Center( // Empty State adaptado
              heightFactor: 2.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.image_search, size: 40, color: getTextColor().withOpacity(0.6)),
                  const SizedBox(height: 8),
                  Text('Aguardando imagem para identificar...', style: TextStyle(fontSize: 14, color: getTextColor().withOpacity(0.6))),
                ],
              ),
            ),
          ),

          // Link Adicionar manualmente
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: TextButton(
                onPressed: _showAddManualIngredientDialog, // Chama o novo modal
                child: const Text(
                  'Adicionar ingrediente manualmente',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: primaryColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 5. Footer Button (Atualizado para desabilitar no loading e chamar a função de busca)
  Widget _buildFooterButton(bool isCurrentDarkMode) {
    return Container(
      margin: const EdgeInsets.only(right: 0,left: 0,top: 0,bottom: 20),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 480,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading || _identifiedIngredients.isEmpty ? null : _searchRecipes, // Desabilita se estiver carregando ou sem ingredientes
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 8,
              shadowColor: primaryColor.withOpacity(0.3),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            child: Text(_isLoading ? 'Analisando Ingredientes...' : 'Buscar Receitas'),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------
// IMPLEMENTAÇÃO DOS WIDGETS CUSTOMIZADOS FALTANTES
// --------------------------------------------------------------------

// 1. CustomAppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  const CustomAppBar({super.key, required this.isDarkMode});

  Color getIconColor() => isDarkMode ? textDark : textLight;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('SnapRecipes', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(icon: Icon(Icons.menu, color: getIconColor()), onPressed: () {}),
      actions: [
        IconButton(icon: Icon(Icons.person_outline, color: getIconColor()), onPressed: () {}),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
