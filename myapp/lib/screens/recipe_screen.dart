import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';

class RecipeRecommendationScreen extends StatefulWidget {
  const RecipeRecommendationScreen({super.key});

  @override
  RecipeRecommendationScreenState createState() =>
      RecipeRecommendationScreenState();
}

class RecipeRecommendationScreenState
    extends State<RecipeRecommendationScreen> {
  final List<Recipe> _recipes = [
    Recipe(
      name: 'Mediterranean Salad',
      description:
          'A healthy and refreshing salad with fresh vegetables and olive oil dressing',
      calories: 320,
      prepTime: '15 mins',
      imageUrl: 'https://example.com/mediterranean-salad.jpg',
      ingredients: [
        'Mixed greens',
        'Cherry tomatoes',
        'Cucumber',
        'Red onion',
        'Olives',
        'Feta cheese',
        'Olive oil',
        'Balsamic vinegar',
      ],
    ),
    Recipe(
      name: 'Grilled Chicken Bowl',
      description:
          'Protein-rich bowl with grilled chicken, quinoa, and roasted vegetables',
      calories: 450,
      prepTime: '25 mins',
      imageUrl: 'https://example.com/chicken-bowl.jpg',
      ingredients: [
        'Chicken breast',
        'Quinoa',
        'Broccoli',
        'Sweet potato',
        'Avocado',
        'Lemon juice',
        'Herbs',
      ],
    ),
    Recipe(
      name: 'Vegetable Stir-Fry',
      description:
          'Quick and nutritious stir-fry with colorful vegetables and tofu',
      calories: 380,
      prepTime: '20 mins',
      imageUrl: 'https://example.com/stir-fry.jpg',
      ingredients: [
        'Tofu',
        'Broccoli',
        'Bell peppers',
        'Snap peas',
        'Carrots',
        'Soy sauce',
        'Ginger',
        'Garlic',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Recipe Recommendations',
          style: AppTheme.headingStyle,
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.bottomNav),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Healthy Recipes',
                style: AppTheme.subheadingStyle.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            recipe.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: AppTheme.primaryLightColor,
                                child: Icon(
                                  Icons.restaurant_rounded,
                                  size: 50,
                                  color: AppTheme.primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.name,
                                style: AppTheme.subheadingStyle.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                recipe.description,
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildRecipeInfo(
                                    Icons.local_fire_department_rounded,
                                    '${recipe.calories} cal',
                                  ),
                                  const SizedBox(width: 16),
                                  _buildRecipeInfo(
                                    Icons.timer_rounded,
                                    recipe.prepTime,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Show recipe details
                                },
                                style: AppTheme.primaryButtonStyle,
                                child: const Text('View Recipe'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class Recipe {
  final String name;
  final String description;
  final int calories;
  final String prepTime;
  final String imageUrl;
  final List<String> ingredients;

  Recipe({
    required this.name,
    required this.description,
    required this.calories,
    required this.prepTime,
    required this.imageUrl,
    required this.ingredients,
  });
}
