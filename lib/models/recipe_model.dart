class Recipe {
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final int prepTime;
  final int servings;
  final String difficulty;
  final String imageUrl;

  const Recipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.prepTime,
    required this.servings,
    required this.difficulty,
    required this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] as String? ?? 'Recette sans titre',
      description: json['description'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      steps: List<String>.from(json['steps'] as List? ?? []),
      prepTime: json['prepTime'] as int? ?? 30,
      servings: json['servings'] as int? ?? 4,
      difficulty: json['difficulty'] as String? ?? 'Moyen',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Recipe copyWith({String? imageUrl}) => Recipe(
        name: name,
        description: description,
        ingredients: ingredients,
        steps: steps,
        prepTime: prepTime,
        servings: servings,
        difficulty: difficulty,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'ingredients': ingredients,
        'steps': steps,
        'prepTime': prepTime,
        'servings': servings,
        'difficulty': difficulty,
        'imageUrl': imageUrl,
      };
}
