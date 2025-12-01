class Recipe {
  final String title;
  final String description;
  final List<String> ingredientsUsed;
  final String instructions;
  final int prepTimeMinutes;
  bool isFavorite; // Agora mutável para permitir update na UI sem recriar tudo instantaneamente

  Recipe({
    required this.title,
    required this.description,
    required this.ingredientsUsed,
    required this.instructions,
    required this.prepTimeMinutes,
    this.isFavorite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] as String,
      description: json['description'] as String,
      ingredientsUsed: List<String>.from(json['ingredientsUsed'] as List),
      instructions: json['instructions'] as String,
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      isFavorite: false, // Padrão da API é false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredientsUsed': ingredientsUsed.join('|'),
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'isFavorite': isFavorite ? 1 : 0, // SQLite usa 0 ou 1
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      title: map['title'] as String,
      description: map['description'] as String,
      ingredientsUsed: (map['ingredientsUsed'] as String).split('|'),
      instructions: map['instructions'] as String,
      prepTimeMinutes: map['prepTimeMinutes'] as int,
      isFavorite: (map['isFavorite'] ?? 0) == 1,
    );
  }
}
