import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class MlService {
  late final ImageLabeler _imageLabeler;

  MlService() {
    final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
    _imageLabeler = ImageLabeler(options: options);
  }

  Future<List<String>> identifyIngredients(XFile imageFile) async {
    final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
    
    try {
      final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);
      
      final List<String> detected = [];
      
      for (ImageLabel label in labels) {
        if (label.label.toLowerCase() != 'food' && 
            label.label.toLowerCase() != 'vegetable' &&
            label.label.toLowerCase() != 'fruit' &&
            label.label.toLowerCase() != 'dish' &&
            label.label.toLowerCase() != 'cuisine' &&
            label.label.toLowerCase() != 'ingredient' &&
            label.label.toLowerCase() != 'table' &&
            label.label.toLowerCase() != 'plate') {
          detected.add(label.label);
        }
      }
      
      return detected;
    } catch (e) {
      throw Exception('Erro no reconhecimento local (ML Kit): $e');
    }
  }
  
  void dispose() {
    _imageLabeler.close();
  }
}
