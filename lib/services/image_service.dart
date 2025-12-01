import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 70,
      );
      return image;
    } catch (e) {
      // Em um cenário real, você pode querer logar esse erro
      // ou encapsulá-lo em uma exceção de domínio personalizada.
      throw Exception('Erro ao acessar a câmera: $e');
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      return image;
    } catch (e) {
      throw Exception('Erro ao acessar a galeria: $e');
    }
  }
}
