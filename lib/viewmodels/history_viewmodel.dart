import 'package:flutter/foundation.dart';
import '../data/repositories/recipe_repository.dart';
import '../services/share_service.dart';
import '../model/recipe.dart';

class HistoryViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final ShareService _shareService;

  HistoryViewModel({
    required RecipeRepository recipeRepository,
    required ShareService shareService,
  })  : _recipeRepository = recipeRepository,
        _shareService = shareService;

  List<Recipe> _savedRecipes = [];
  bool _isLoading = true;

  List<Recipe> get savedRecipes => _savedRecipes;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _savedRecipes = await _recipeRepository.getAllSavedRecipes();
    } catch (e) {
      print('Erro ao carregar histórico: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    await _recipeRepository.toggleFavorite(recipe);
    notifyListeners();
  }

  Future<void> shareRecipe(Recipe recipe, {bool asPdf = false}) async {
    if (asPdf) {
      await _shareService.shareRecipePdf(recipe);
    } else {
      await _shareService.shareRecipeText(recipe);
    }
  }
}
