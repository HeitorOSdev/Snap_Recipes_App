class Recipe {
  final String title;
  final String description;
  final List<String> ingredientsUsed;
  final String instructions;
  final int prepTimeMinutes;

  Recipe({
    required this.title,
    required this.description,
    required this.ingredientsUsed,
    required this.instructions,
    required this.prepTimeMinutes,
  });

  // Método de fábrica para criar uma receita a partir de um mapa
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] as String,
      description: json['description'] as String,
      ingredientsUsed: List<String>.from(json['ingredientsUsed'] as List),
      instructions: json['instructions'] as String,
      prepTimeMinutes: json['prepTimeMinutes'] as int,
    );
  }
}