import '../../model/recipe.dart';
import '../../services/api_service.dart';
import '../datasources/local_data_source.dart';

class RecipeRepository {
  final ApiService _apiService;
  final LocalDataSource _localDataSource;

  RecipeRepository({
    required ApiService apiService,
    required LocalDataSource localDataSource,
  })  : _apiService = apiService,
        _localDataSource = localDataSource;

  Future<List<Recipe>> getRecipes(List<String> ingredients) async {
    try {
      // 1. Tenta buscar na API
      print('Repository: Buscando na API...');
      final recipes = await _apiService.fetchRecipes(ingredients);
      
      // 2. Salva no banco local, respeitando favoritos existentes
      if (recipes.isNotEmpty) {
        print('Repository: Atualizando cache local...');
        await _localDataSource.saveRecipes(recipes);
      }
      
      final cachedRecipes = await _localDataSource.getRecipes();
      
      for (var apiRecipe in recipes) {
         final match = cachedRecipes.firstWhere(
             (local) => local.title == apiRecipe.title, 
             orElse: () => apiRecipe
         );
         apiRecipe.isFavorite = match.isFavorite;
      }
      
      return recipes;

    } catch (e) {
      print('Repository: Falha na API ($e). Buscando no banco local...');
      final localRecipes = await _localDataSource.getRecipes();
      
      if (localRecipes.isNotEmpty) {
        return localRecipes;
      } else {
        throw Exception('Sem conexão e sem receitas salvas.');
      }
    }
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    recipe.isFavorite = !recipe.isFavorite;
    await _localDataSource.updateFavoriteStatus(recipe);
  }

  Future<List<Recipe>> getFavorites() async {
    return await _localDataSource.getFavoriteRecipes();
  }

  // Novo método para buscar TODAS as receitas salvas
  Future<List<Recipe>> getAllSavedRecipes() async {
    return await _localDataSource.getRecipes();
  }
}
