import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../routes/app_router.dart';
import '../state/user_state.dart';
import '../theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'allergen_entry_screen.dart';
import 'recipe_detail_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<dynamic> recipes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = Provider.of<UserState>(context, listen: false);
      if (userState.isLoggedIn) {
        fetchRecipes();
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }

  Future<void> fetchRecipes() async {
    final userState = Provider.of<UserState>(context, listen: false);
    setState(() {
      loading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('https://6a8a-2407-d000-d-51ae-f02d-ab60-def7-f982.ngrok-free.app/recipes/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'allergens': userState.allergens}),
      ).timeout(const Duration(seconds: 10)); // <-- Add timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recipes = data['recipes'] ?? [];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch recipes: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recipes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

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
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          if (!userState.isLoggedIn)
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            )
          else
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllergenEntryScreen()),
                );
                // Always fetch recipes after editing allergens
                fetchRecipes();
              },
              child: const Text('Edit Allergens', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
              ? const Center(child: Text('No safe recipes found!'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userState.isLoggedIn && userState.allergens.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8,
                          children: userState.allergens
                              .map((a) => Chip(label: Text(a)))
                              .toList(),
                        ),
                      ),
                    Expanded(
                      child: Container(
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
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailScreen(recipeId: recipe['id']),
                                  ),
                                );
                              },
                              child: Container(
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
                                        recipe['image'] ?? '',
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
                                            recipe['title'] ?? 'No Title',
                                            style: AppTheme.subheadingStyle.copyWith(
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'ID: ${recipe['id']}',
                                            style: AppTheme.bodyStyle.copyWith(
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
