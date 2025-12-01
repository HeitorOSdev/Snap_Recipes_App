import 'package:flutter/foundation.dart';
import '../data/repositories/recipe_repository.dart';
import '../services/share_service.dart';
import '../model/recipe.dart';

class RecipeResultsViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final ShareService _shareService;

  RecipeResultsViewModel({
    required RecipeRepository recipeRepository,
    required ShareService shareService,
  })  : _recipeRepository = recipeRepository,
        _shareService = shareService;
  
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRecipes(List<String> ingredients) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (ingredients.isEmpty) {
        _errorMessage = 'Nenhum ingrediente fornecido.';
      } else {
        _recipes = await _recipeRepository.getRecipes(ingredients);
      }
    } catch (e) {
      _errorMessage = e.toString();
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
