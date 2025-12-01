import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../model/recipe.dart';

class LocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'snap_recipes_v2.db'); // Alterei o nome para forçar criação nova

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            ingredientsUsed TEXT,
            instructions TEXT,
            prepTimeMinutes INTEGER,
            isFavorite INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // Salva uma lista de receitas (Cache)
  // ATENÇÃO: Agora não podemos simplesmente deletar tudo ou sobrescrever cegamente,
  // pois perderíamos o status de favorito se a receita já existir.
  Future<void> saveRecipes(List<Recipe> recipes) async {
    final db = await database;
    final batch = db.batch();

    for (var recipe in recipes) {
      // Verifica se a receita já existe para preservar o status de favorito
      final List<Map<String, dynamic>> existing = await db.query(
        'recipes',
        where: 'title = ?',
        whereArgs: [recipe.title],
      );

      if (existing.isNotEmpty) {
        // Se existe, mantemos o status de favorito que estava no banco
        final isFav = (existing.first['isFavorite'] ?? 0) == 1;
        recipe.isFavorite = isFav; 
        
        // Atualizamos os outros campos (descrição, etc) mas mantemos o ID e Favorito
        batch.update(
          'recipes',
          recipe.toMap(),
          where: 'title = ?',
          whereArgs: [recipe.title],
        );
      } else {
        // Se não existe, insere
        batch.insert('recipes', recipe.toMap());
      }
    }
    
    await batch.commit(noResult: true);
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes', orderBy: "id DESC");

    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }
  
  Future<List<Recipe>> getFavoriteRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes', 
      where: 'isFavorite = 1',
      orderBy: "id DESC"
    );

    return List.generate(maps.length, (i) => Recipe.fromMap(maps[i]));
  }

  Future<void> updateFavoriteStatus(Recipe recipe) async {
    final db = await database;
    
    // Primeiro verificamos se a receita existe no banco
    // (Pode ser que estejamos tentando favoritar uma receita que veio da API e ainda não foi salva,
    // embora nossa lógica atual salve tudo no cache, é bom garantir).
    
    final List<Map<String, dynamic>> existing = await db.query(
      'recipes',
      where: 'title = ?',
      whereArgs: [recipe.title],
    );

    if (existing.isEmpty) {
      // Se não existe (caso raro na nossa arquitetura atual), insere como favorita
      recipe.isFavorite = true;
      await db.insert('recipes', recipe.toMap());
    } else {
      // Se existe, atualiza apenas o campo isFavorite
      await db.update(
        'recipes',
        {'isFavorite': recipe.isFavorite ? 1 : 0},
        where: 'title = ?',
        whereArgs: [recipe.title],
      );
    }
  }
}
