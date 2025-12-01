import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaprecipes/core/theme/app_theme.dart';
import 'package:snaprecipes/viewmodels/home_viewmodel.dart';
import 'package:snaprecipes/ui/pages/recipe_results_page.dart';
import 'package:snaprecipes/ui/pages/favorites_page.dart';
import 'package:snaprecipes/ui/pages/history_page.dart';
import 'package:snaprecipes/ui/widgets/headlineSection.dart';
import 'package:snaprecipes/ui/widgets/ingredientChip.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Listener para exibir erros caso ocorram
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage!)),
        );
        viewModel.clearError();
      });
    }

    // Listener para exibir aviso de modo offline
    if (viewModel.isOfflineMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sem internet. Reconhecimento por foto e receitas ambos limitados.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        // Não limpamos a flag imediatamente para não entrar em loop se o build for chamado de novo,
        // mas o viewModel.clearError() lá em cima cuida de resetar estados quando novas ações ocorrem.
        // O ideal seria consumir o evento apenas uma vez.
      });
    }

    return Scaffold(
      appBar: CustomAppBar(isDarkMode: isDarkMode),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    HeadlineSection(isDarkMode: isDarkMode),
                    _buildCameraButton(context, viewModel),
                    _buildIngredientsSection(context, viewModel, isDarkMode),
                  ],
                ),
              ),
            ),
          ),
          _buildFooterButton(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildCameraButton(BuildContext context, HomeViewModel viewModel) {
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
            onTap: viewModel.isLoading ? null : viewModel.pickImageAndAnalyze,
            borderRadius: BorderRadius.circular(9999),
            child: Center(
              child: viewModel.isLoading
                  ? const CircularProgressIndicator(color: textLight)
                  : Icon(
                viewModel.pickedImage == null ? Icons.photo_camera : Icons.check_circle_outline,
                color: textLight,
                size: 80,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context, HomeViewModel viewModel, bool isDarkMode) {
    final Color subtleBgColor = isDarkMode ? subtleDark : subtleLight;
    final Color borderColor = isDarkMode ? borderDark : borderLight;
    final Color textColor = isDarkMode ? textDark : textLight;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const Text(
              'Ingredientes Identificados',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: subtleBgColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor),
            ),
            child: viewModel.identifiedIngredients.isNotEmpty
                ? Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: viewModel.identifiedIngredients.map((name) => IngredientChip(
                name: name,
                isDarkMode: isDarkMode,
                onRemove: () => viewModel.removeIngredient(name),
              )).toList(),
            )
                : Center(
              heightFactor: 2.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.image_search, size: 40, color: textColor.withOpacity(0.6)),
                  const SizedBox(height: 8),
                  Text('Aguardando imagem para identificar...', style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6))),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: TextButton(
                onPressed: () => _showAddManualIngredientDialog(context, viewModel, isDarkMode),
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

  void _showAddManualIngredientDialog(BuildContext context, HomeViewModel viewModel, bool isDarkMode) {
    String newIngredient = '';
    final textColor = isDarkMode ? textDark : textLight;
    final borderColor = isDarkMode ? borderDark : borderLight;
    final bgColor = isDarkMode ? backgroundDark : backgroundLight;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: bgColor,
          title: Text(
              'Adicionar Ingrediente',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
          ),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ex: Batata, Cenoura...',
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
            style: TextStyle(color: textColor),
            onChanged: (value) => newIngredient = value,
            onSubmitted: (value) {
              viewModel.addManualIngredient(value);
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: textColor.withOpacity(0.7))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.addManualIngredient(newIngredient);
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

  Widget _buildFooterButton(BuildContext context, HomeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 480,
          height: 56,
          child: ElevatedButton(
            onPressed: viewModel.isLoading || viewModel.identifiedIngredients.isEmpty
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeResultsPage(
                    ingredients: viewModel.identifiedIngredients,
                  ),
                ),
              );
            },
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
            child: Text(viewModel.isLoading ? 'Analisando Ingredientes...' : 'Buscar Receitas'),
          ),
        ),
      ),
    );
  }
}

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
      leading: IconButton(
        icon: Icon(Icons.history, color: getIconColor()),
        tooltip: 'Histórico',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryPage()),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.favorite, color: Colors.red.withOpacity(0.8)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            );
          },
          tooltip: 'Ver Favoritos',
        ),
        IconButton(icon: Icon(Icons.person_outline, color: getIconColor()), onPressed: () {}),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
