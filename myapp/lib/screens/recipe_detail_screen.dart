// recipe_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map? details;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    // Replace YOUR_API_KEY with your Spoonacular API key
    final url = 'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=7bb378a3d04a4accb92f61c3a3ddd940';
    final response = await http.get(Uri.parse(url));
    print('Recipe details status: ${response.statusCode}');
    print('Recipe details body: ${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        details = jsonDecode(response.body);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (details == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load recipe details')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(details!['title'] ?? 'Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details!['image'] != null)
              Image.network(details!['image']),
            const SizedBox(height: 16),
            Text(
              details!['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (details!['extendedIngredients'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(
                    details!['extendedIngredients'].length,
                    (i) => Text('• ${details!['extendedIngredients'][i]['original']}'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (details!['instructions'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(details!['instructions']),
                ],
              ),
          ],
        ),
      ),
    );
  }
}