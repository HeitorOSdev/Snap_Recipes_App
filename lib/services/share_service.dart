import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../model/recipe.dart';
import 'pdf_service.dart';

class ShareService {
  final PdfService _pdfService = PdfService();

  Future<void> shareRecipeText(Recipe recipe) async {
    final text = '''
🍳 *${recipe.title}* (${recipe.prepTimeMinutes} min)
    
${recipe.description}

📝 *Ingredientes:*
${recipe.ingredientsUsed.map((e) => '- $e').join('\n')}

🥣 *Modo de Preparo:*
${recipe.instructions}

_Gerado por SnapRecipes_
    ''';

    await Share.share(text);
  }

  Future<void> shareRecipePdf(Recipe recipe) async {
    try {
      final File pdfFile = await _pdfService.generateRecipePdf(recipe);
      final xFile = XFile(pdfFile.path);
      
      await Share.shareXFiles(
        [xFile],
        text: 'Confira esta receita incrível de ${recipe.title}!',
      );
    } catch (e) {
      throw Exception('Erro ao gerar ou compartilhar PDF: $e');
    }
  }
}
