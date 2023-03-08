import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Tes with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Tes({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void togleFavoriteStatus() {
    final url = Uri.https(
        'hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products/$id.json');
    http.patch(url, body: json.encode({'isFavorite': !isFavorite}));
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
