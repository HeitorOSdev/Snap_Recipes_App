import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/repositories/ingredient_repository.dart';
import '../services/image_service.dart';
import '../services/connectivity_service.dart';

class HomeViewModel extends ChangeNotifier {
  final IngredientRepository _ingredientRepository;
  final ImageService _imageService;
  final ConnectivityService _connectivityService; // Novo serviço

  HomeViewModel({
    required IngredientRepository ingredientRepository,
    required ImageService imageService,
    required ConnectivityService connectivityService,
  })  : _ingredientRepository = ingredientRepository,
        _imageService = imageService,
        _connectivityService = connectivityService;

  List<String> _identifiedIngredients = ['Tomate', 'Cebola', 'Manjericão'];
  XFile? _pickedImage;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false; // Estado para controlar o aviso

  List<String> get identifiedIngredients => _identifiedIngredients;
  XFile? get pickedImage => _pickedImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOfflineMode => _isOfflineMode;

  void clearError() {
    _errorMessage = null;
    _isOfflineMode = false; // Limpa o aviso também
    notifyListeners();
  }

  Future<void> pickImageAndAnalyze() async {
    if (_isLoading) return;

    try {
      final XFile? image = await _imageService.pickImageFromCamera();

      if (image != null) {
        _pickedImage = image;
        notifyListeners();
        await _analyzeImage(image);
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _analyzeImage(XFile imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    _isOfflineMode = false;
    notifyListeners();

    try {
      // Verifica conectividade antes
      final hasInternet = await _connectivityService.isConnected;
      
      if (!hasInternet) {
        _isOfflineMode = true;
        // Não bloqueamos, apenas avisamos. O fluxo continua.
      }

      // O repositório já tem a lógica de fallback, mas agora sabemos o estado na UI
      final newIngredients = await _ingredientRepository.identifyIngredients(imageFile);
      
      if (newIngredients.isNotEmpty) {
        for (var ing in newIngredients) {
          final capitalized = ing.trim().isNotEmpty
              ? ing.trim()[0].toUpperCase() + ing.trim().substring(1).toLowerCase()
              : '';
              
          if (capitalized.isNotEmpty && !_identifiedIngredients.contains(capitalized)) {
            _identifiedIngredients.add(capitalized);
          }
        }
      } else {
        _errorMessage = 'Não foi possível identificar ingredientes na imagem.';
      }
    } catch (e) {
      _errorMessage = 'Erro ao analisar a imagem: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeIngredient(String ingredient) {
    _identifiedIngredients.remove(ingredient);
    notifyListeners();
  }

  void addManualIngredient(String ingredient) {
    final capitalized = ingredient.trim().isNotEmpty
        ? ingredient.trim()[0].toUpperCase() + ingredient.trim().substring(1).toLowerCase()
        : '';

    if (capitalized.isNotEmpty && !_identifiedIngredients.contains(capitalized)) {
      _identifiedIngredients.add(capitalized);
      notifyListeners();
    }
  }
}
