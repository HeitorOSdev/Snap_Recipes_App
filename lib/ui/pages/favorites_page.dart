import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaprecipes/core/theme/app_theme.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../ui/widgets/recipe_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesViewModel>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color getTextColor() => isDarkMode ? textDark : textLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
        iconTheme: IconThemeData(color: getTextColor()),
        titleTextStyle: TextStyle(color: getTextColor(), fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (viewModel.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: getTextColor().withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Você ainda não tem favoritos.',
                    style: TextStyle(color: getTextColor().withOpacity(0.6), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.favorites.length,
            itemBuilder: (context, index) {
              final recipe = viewModel.favorites[index];
              return RecipeCard(
                recipe: recipe,
                isDarkMode: isDarkMode,
                onFavoriteToggle: () => viewModel.removeFavorite(recipe),
                onShare: (asPdf) => viewModel.shareRecipe(recipe, asPdf: asPdf),
              );
            },
          );
        },
      ),
    );
  }
}
