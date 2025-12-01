// ingredient_chip.dart
import 'package:flutter/material.dart';
import 'package:snaprecipes/core/theme/app_theme.dart';

class IngredientChip extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;
  final bool isDarkMode;

  const IngredientChip({
    super.key,
    required this.name,
    required this.onRemove,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Mapeamento de Cores Dinâmicas
    final Color bgColor = isDarkMode ? backgroundDark : backgroundLight; // bg-background-light dark:bg-background-dark
    final Color borderColor = isDarkMode ? borderDark : borderLight;   // border-border-light dark:border-border-dark
    final Color chipTextColor = isDarkMode ? textDark : textLight;

    // Cores específicas para o botão de fechar
    final Color closeBgColor = isDarkMode ? subtleDark : subtleLight; // bg-subtle-light dark:bg-subtle-dark
    final Color closeIconColor = isDarkMode ? textDark.withOpacity(0.7) : textLight.withOpacity(0.7); // text-text-light/70

    return Container(
      // Estilos do Chip Principal (Container)
      padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0, right: 8.0), // py-2 pl-3 pr-2
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999), // rounded-full
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
        children: <Widget>[
          // Texto do Ingrediente (<span>)
          Text(
            name,
            style: TextStyle(
              fontSize: 14, // text-sm
              fontWeight: FontWeight.w500, // font-medium
              color: chipTextColor,
            ),
          ),
          const SizedBox(width: 8),

          // Botão Fechar (<button>)
          InkWell(
            onTap: onRemove, // Executa a função passada por parâmetro
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              width: 24, // size-6
              height: 24,
              decoration: BoxDecoration(
                color: closeBgColor,
                shape: BoxShape.circle,
                // O efeito 'hover:bg-red-100' é alcançado pelo InkWell (Material) e deve ser tratado em um tema
              ),
              child: Icon(
                Icons.close,
                size: 16, // !text-base (cerca de 16px)
                color: closeIconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
