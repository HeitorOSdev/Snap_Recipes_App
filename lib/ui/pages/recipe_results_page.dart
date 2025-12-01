import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaprecipes/core/theme/app_theme.dart';
import '../../viewmodels/recipe_results_viewmodel.dart';
import '../../ui/widgets/recipe_card.dart';

class RecipeResultsPage extends StatefulWidget {
  final List<String> ingredients;

  const RecipeResultsPage({
    super.key,
    required this.ingredients,
  });

  @override
  State<RecipeResultsPage> createState() => _RecipeResultsPageState();
}

class _RecipeResultsPageState extends State<RecipeResultsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeResultsViewModel>(context, listen: false)
          .fetchRecipes(widget.ingredients);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color getTextColor() => isDarkMode ? textDark : textLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados da Receita', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
        iconTheme: IconThemeData(color: getTextColor()),
        titleTextStyle: TextStyle(color: getTextColor(), fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      body: Consumer<RecipeResultsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
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

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red.shade400, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (viewModel.recipes.isEmpty) {
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
              ...viewModel.recipes.map((recipe) => RecipeCard(
                recipe: recipe,
                isDarkMode: isDarkMode,
                onFavoriteToggle: () => viewModel.toggleFavorite(recipe),
                onShare: (asPdf) => viewModel.shareRecipe(recipe, asPdf: asPdf),
              )).toList(),
            ],
          );
        },
      ),
    );
  }
}
