import 'package:flutter/material.dart';
import 'package:snaprecipes/ui/widgets/customAppBar.dart';
import 'package:snaprecipes/ui/widgets/headlineSection.dart';
import 'package:snaprecipes/ui/widgets/ingredientChip.dart';

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
const String fontDisplay = 'Plus Jakarta Sans'; // Você precisaria adicionar esta fonte ao pubspec.yaml

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
        // Configurações básicas de tema (simulando o modo claro)
        scaffoldBackgroundColor: backgroundLight,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textLight),
          titleLarge: TextStyle(color: textLight),
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          background: backgroundLight,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: fontDisplay,
        // Configurações básicas de tema (simulando o modo escuro)
        scaffoldBackgroundColor: backgroundDark,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textDark),
          titleLarge: TextStyle(color: textDark),
        ),
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          background: backgroundDark,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(isDarkMode: false), // Defina isDarkMode conforme o estado do app
    );
  }
}

class MainPage extends StatelessWidget {
  final bool isDarkMode;
  const MainPage({super.key, required this.isDarkMode});

  // Função auxiliar para obter a cor correta baseada no modo
  Color getTextColor() => isDarkMode ? textDark : textLight;
  Color getBgColor() => isDarkMode ? backgroundDark : backgroundLight;
  Color getSubtleBgColor() => isDarkMode ? subtleDark : subtleLight;
  Color getBorderColor() => isDarkMode ? borderDark : borderLight;

  @override
  Widget build(BuildContext context) {
    // Media Query para acessar o modo de cor atual do sistema, se não for forçado
    final isCurrentDarkMode = isDarkMode || Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // AppBar (Top App Bar)
      appBar: CustomAppBar(isDarkMode: isDarkMode),

      // Corpo Principal (Main Content)
      body: Column(
        children: <Widget>[
          // Conteúdo central que irá se expandir (Headline, Botão da Câmera, Ingredientes)
          Expanded(
            child: SingleChildScrollView( // Para garantir que a tela seja rolável, se necessário
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Headline & Body Text
                    HeadlineSection(),

                    // Main Action: Camera Button
                    _buildCameraButton(),

                    // Identified Ingredients Section
                    _buildIngredientsSection(isCurrentDarkMode),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Button (Footer)
          _buildFooterButton(isCurrentDarkMode),

        ],
      ),
    );
  }

  // --- Widgets de Construção da UI ---


  // 3. Camera Button
  Widget _buildCameraButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Container(
        width: 192, // w-48 (48 * 4 = 192)
        height: 192, // h-48
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3), // shadow-primary/30
              spreadRadius: 0,
              blurRadius: 10, // Simulação de shadow-lg
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(9999), // rounded-full
          child: InkWell(
            onTap: () {
              // Ação do botão da Câmera
              print('Abrir Câmera');
            },
            borderRadius: BorderRadius.circular(9999),
            child: const Center(
              child: Icon(
                Icons.photo_camera,
                color: textLight, // text-text-light
                size: 80, // !text-7xl (cerca de 72-80px)
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 4. Ingredients Section
  Widget _buildIngredientsSection(bool isCurrentDarkMode) {
    final List<String> ingredients = ['Tomate', 'Cebola', 'Manjericão'];
    final Color subtleBgColor = isCurrentDarkMode ? subtleDark : subtleLight;
    final Color borderColor = isCurrentDarkMode ? borderDark : borderLight;

    return Container(
      width: double.infinity, // w-full
      constraints: const BoxConstraints(maxWidth: 480), // max-w-lg mx-auto
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
              borderRadius: BorderRadius.circular(16.0), // rounded-xl
              border: Border.all(color: borderColor),
            ),

            child:
            Wrap(
              spacing: 12.0, // gap-3 (Tailwind usa 12px para gap-3)
              runSpacing: 12.0,
              children: ingredients.map((name) => IngredientChip(
                name: name,
                isDarkMode: isDarkMode, // Passar o estado correto aqui
                onRemove: () {
                  print('Remover Tomate');
                  // Adicionar lógica de estado para remover o chip da lista
                },
              )).toList(),
            ),
            // Se precisar do Empty State, descomentar o código abaixo:
            /*
            child: const Center(
              heightFactor: 2.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.image_search, size: 40, color: textLight.withOpacity(0.6)),
                  SizedBox(height: 8),
                  Text('Aguardando imagem para identificar...', style: TextStyle(fontSize: 14, color: textLight.withOpacity(0.6))),
                ],
              ),
            ),
            */
          ),

          // Link Adicionar manualmente
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: TextButton(
                onPressed: () {
                  print('Adicionar manualmente');
                },
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

  // 4.1. Ingredient Chip

  // 5. Footer Button
  Widget _buildFooterButton(bool isCurrentDarkMode) {
    final Color footerBgColor = isCurrentDarkMode ? backgroundDark : backgroundLight;

    return Container(
      margin: EdgeInsetsGeometry.only(right: 0,left: 0,top: 0,bottom: 20),
      // Simulação do gradiente 'bg-gradient-to-t from-background-light to-transparent'
      decoration: BoxDecoration(


      ),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(

          width: 480, // max-w-[480px]
          height: 56, // h-14
          child: ElevatedButton(
            onPressed: () {
              print('Buscar Receitas');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: textLight,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // rounded-xl
              ),
              elevation: 8, // Simulação de shadow-lg
              shadowColor: primaryColor.withOpacity(0.3), // shadow-primary/30
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            child: const Text('Buscar Receitas'),
          ),
        ),
      ),
    );
  }
}
