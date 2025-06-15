// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/user_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllergenEntryScreen extends StatefulWidget {
  const AllergenEntryScreen({super.key});

  @override
  State<AllergenEntryScreen> createState() => _AllergenEntryScreenState();
}

class _AllergenEntryScreenState extends State<AllergenEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _allergens = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill with current allergens
    final userState = Provider.of<UserState>(context, listen: false);
    _allergens = List<String>.from(userState.allergens);
  }

  void _addAllergen() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_allergens.contains(text)) {
      setState(() {
        _allergens.add(text);
        _controller.clear();
      });
    }
  }

  Future<void> _saveAllergens() async {
    final userState = Provider.of<UserState>(context, listen: false);
    final userId = userState.userId;
    print('Saving allergens for userId: $userId, allergens: $_allergens');
    try {
      final response = await http.post(
        Uri.parse('https://db37-2407-d000-d-33c2-15fd-c4ba-2d0-db4d.ngrok-free.app/user/allergens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'allergens': _allergens}),
      );
      print('SaveAllergens status: ${response.statusCode}');
      print('SaveAllergens body: ${response.body}');
      if (response.statusCode == 200) {
        Provider.of<UserState>(context, listen: false).setAllergens(_allergens);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save allergens')),
        );
      }
    } catch (e) {
      print('SaveAllergens error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Allergens')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Add Allergen'),
              onSubmitted: (_) => _addAllergen(),
            ),
            ElevatedButton(
              onPressed: _addAllergen,
              child: const Text('Add'),
            ),
            Wrap(
              children: _allergens
                  .map((a) => Chip(
                        label: Text(a),
                        onDeleted: () {
                          setState(() {
                            _allergens.remove(a);
                          });
                        },
                      ))
                  .toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveAllergens,
              child: const Text('Save Allergens'),
            ),
          ],
        ),
      ),
    );
  }
}