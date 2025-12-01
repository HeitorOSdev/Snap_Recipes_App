import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaprecipes/core/theme/app_theme.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../ui/widgets/recipe_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryViewModel>(context, listen: false).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color getTextColor() => isDarkMode ? textDark : textLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Receitas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
        iconTheme: IconThemeData(color: getTextColor()),
        titleTextStyle: TextStyle(color: getTextColor(), fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (viewModel.savedRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: getTextColor().withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma receita salva no histórico.',
                    style: TextStyle(color: getTextColor().withOpacity(0.6), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.savedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = viewModel.savedRecipes[index];
              return RecipeCard(
                recipe: recipe,
                isDarkMode: isDarkMode,
                onFavoriteToggle: () => viewModel.toggleFavorite(recipe),
                onShare: (asPdf) => viewModel.shareRecipe(recipe, asPdf: asPdf),
              );
            },
          );
        },
      ),
    );
  }
}
