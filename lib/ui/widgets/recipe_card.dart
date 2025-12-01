import 'package:flutter/material.dart';
import 'package:snaprecipes/core/theme/app_theme.dart';
import '../../model/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isDarkMode;
  final VoidCallback onFavoriteToggle;
  final Function(bool asPdf) onShare; // Callback para compartilhar

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isDarkMode,
    required this.onFavoriteToggle,
    required this.onShare,
  });

  Color getTextColor() => isDarkMode ? textDark : textLight;
  Color getBorderColor() => isDarkMode ? borderDark : borderLight;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  recipe.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: getTextColor(),
                  ),
                ),
              ),
              Row(
                children: [
                  // Botão Compartilhar
                  IconButton(
                    icon: Icon(Icons.share, color: getTextColor().withOpacity(0.7)),
                    onPressed: () {
                      // Mostra BottomSheet para escolher Texto ou PDF
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.text_fields),
                                title: const Text('Compartilhar Texto'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onShare(false);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.picture_as_pdf),
                                title: const Text('Compartilhar PDF'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onShare(true);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Botão Favorito
                  IconButton(
                    icon: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: recipe.isFavorite ? Colors.red : getTextColor().withOpacity(0.5),
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
            ],
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
          // ... (resto do código igual)
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
