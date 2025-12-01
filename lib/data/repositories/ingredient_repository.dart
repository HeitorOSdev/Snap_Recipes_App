import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../services/ml_service.dart';
import '../../services/connectivity_service.dart';

class IngredientRepository {
  final ApiService _apiService;
  final MlService _mlService;
  final ConnectivityService _connectivityService;

  IngredientRepository({
    required ApiService apiService,
    required MlService mlService,
    required ConnectivityService connectivityService,
  })  : _apiService = apiService,
        _mlService = mlService,
        _connectivityService = connectivityService;

  Future<List<String>> identifyIngredients(XFile imageFile) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        print('IngredientRepository: Online. Usando API Gemini...');
        return await _apiService.identifyIngredients(imageFile);
      } catch (e) {
        print('IngredientRepository: Falha na API ($e). Tentando ML Kit local...');
        // Fallback para local se a API falhar mesmo com internet (timeout, erro 500, etc)
        return await _mlService.identifyIngredients(imageFile);
      }
    } else {
      print('IngredientRepository: Offline. Usando ML Kit local...');
      return await _mlService.identifyIngredients(imageFile);
    }
  }
}
