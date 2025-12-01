import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../services/api_service.dart';
import '../../services/image_service.dart';
import '../../services/share_service.dart';
import '../../services/ml_service.dart';
import '../../services/connectivity_service.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/recipe_results_viewmodel.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';

class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {
    final apiService = ApiService();
    final imageService = ImageService();
    final shareService = ShareService();
    final mlService = MlService();
    final connectivityService = ConnectivityService();
    final localDataSource = LocalDataSource();
    
    final recipeRepository = RecipeRepository(
      apiService: apiService,
      localDataSource: localDataSource,
    );

    final ingredientRepository = IngredientRepository(
      apiService: apiService,
      mlService: mlService,
      connectivityService: connectivityService,
    );

    return ConfigureProviders(providers: [
      Provider<ApiService>.value(value: apiService),
      Provider<ImageService>.value(value: imageService),
      Provider<ShareService>.value(value: shareService),
      Provider<MlService>.value(value: mlService),
      Provider<ConnectivityService>.value(value: connectivityService),
      Provider<LocalDataSource>.value(value: localDataSource),
      
      Provider<RecipeRepository>.value(value: recipeRepository),
      Provider<IngredientRepository>.value(value: ingredientRepository),

      ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(
          ingredientRepository: ingredientRepository,
          imageService: imageService,
          connectivityService: connectivityService,
        ),
      ),
      ChangeNotifierProvider<RecipeResultsViewModel>(
        create: (context) => RecipeResultsViewModel(
          recipeRepository: recipeRepository,
          shareService: shareService,
        ),
      ),
      ChangeNotifierProvider<FavoritesViewModel>(
        create: (context) => FavoritesViewModel(
          recipeRepository: recipeRepository,
          shareService: shareService,
        ),
      ),
      ChangeNotifierProvider<HistoryViewModel>(
        create: (context) => HistoryViewModel(
          recipeRepository: recipeRepository,
          shareService: shareService,
        ),
      ),
    ]);
  }
}
