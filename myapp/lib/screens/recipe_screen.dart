import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';

class RecipeRecommendationScreen extends StatelessWidget {
  final List<String> recipes = [
    'Grilled Chicken Salad',
    'Quinoa Bowl',
    'Vegetable Stir Fry',
    'Smoothie Bowl',
  ];

  RecipeRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Recommendations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.bottomNav),
        ),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipes[index]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recipe details for ${recipes[index]}')),
              );
            },
          );
        },
      ),
    );
  }
}
