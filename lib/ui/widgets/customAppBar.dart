// custom_app_bar.dart
import 'package:flutter/material.dart';
// Importe as constantes de cor se estiverem em outro arquivo

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  const CustomAppBar({super.key, required this.isDarkMode});

  // Mapeamento de cores (repetido aqui apenas para demonstração)
  static const Color textLight = Color(0xFF111b0d);
  static const Color textDark = Color(0xFFe8f5e9);
  static const Color backgroundLight = Color(0xFFf6f8f6);
  static const Color backgroundDark = Color(0xFF142210);

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkMode ? textDark : textLight;
    final Color bgColor = isDarkMode ? backgroundDark : backgroundLight;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      // ... (Resto do código do Row e Ícones)
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Icone Menu
            const SizedBox(
              width: 48, height: 48, child: Center(child: Icon(Icons.menu, size: 30)),
            ),
            // Título
            Expanded(
              child: Text(
                'RecipeApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            // Botão More Vert
            SizedBox(
              width: 48, height: 48,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, size: 30),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Altura padrão da AppBar
}