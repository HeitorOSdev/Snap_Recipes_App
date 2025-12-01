import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../model/recipe.dart';

class PdfService {
  Future<File> generateRecipePdf(Recipe recipe) async {
    final pdf = pw.Document();
    
    // Carrega a fonte (opcional, usa padrão se não tiver)
    final font = await PdfGoogleFonts.nunitoExtraLight();
    final fontBold = await PdfGoogleFonts.nunitoExtraBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('SnapRecipes', style: pw.TextStyle(font: fontBold, fontSize: 20, color: PdfColors.green)),
                    pw.Text('Receita Gerada por IA', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(recipe.title, style: pw.TextStyle(font: fontBold, fontSize: 24)),
              pw.SizedBox(height: 10),
              pw.Text('${recipe.prepTimeMinutes} min de preparo', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.green800)),
              pw.SizedBox(height: 20),
              pw.Text(recipe.description, style: pw.TextStyle(font: font, fontSize: 14)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Ingredientes:', style: pw.TextStyle(font: fontBold, fontSize: 18)),
              pw.SizedBox(height: 5),
              pw.Wrap(
                spacing: 5,
                runSpacing: 5,
                children: recipe.ingredientsUsed.map((ing) => 
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: PdfColors.green200),
                    ),
                    child: pw.Text(ing, style: pw.TextStyle(font: font, fontSize: 10)),
                  )
                ).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Instruções:', style: pw.TextStyle(font: fontBold, fontSize: 18)),
              pw.SizedBox(height: 5),
              pw.Text(recipe.instructions, style: pw.TextStyle(font: font, fontSize: 12, lineSpacing: 2)),
              pw.Spacer(),
              pw.Footer(
                leading: pw.Text('Gerado em ${DateTime.now().toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    return await _savePdfFile(pdf, 'recipe_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  Future<File> _savePdfFile(pw.Document pdf, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
