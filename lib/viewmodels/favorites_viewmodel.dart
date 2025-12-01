import 'package:flutter/foundation.dart';
import '../data/repositories/recipe_repository.dart';
import '../services/share_service.dart';
import '../model/recipe.dart';

class FavoritesViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final ShareService _shareService;

  FavoritesViewModel({
    required RecipeRepository recipeRepository,
    required ShareService shareService,
  })  : _recipeRepository = recipeRepository,
        _shareService = shareService;

  List<Recipe> _favorites = [];
  bool _isLoading = true;

  List<Recipe> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _recipeRepository.getFavorites();
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFavorite(Recipe recipe) async {
    await _recipeRepository.toggleFavorite(recipe);
    await loadFavorites(); 
  }

  Future<void> shareRecipe(Recipe recipe, {bool asPdf = false}) async {
    if (asPdf) {
      await _shareService.shareRecipePdf(recipe);
    } else {
      await _shareService.shareRecipeText(recipe);
    }
  }
}
