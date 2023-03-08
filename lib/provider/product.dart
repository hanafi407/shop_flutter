import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool? isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  _setFavValue(bool newVal) {
    isFavorite = newVal;
    notifyListeners();
  }

  Future<void> togleFavoriteStatus() async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite!;
    notifyListeners();
    final url = Uri.https(
        'hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products/$id');
    try {
      var res = await http.patch(
        url,
        body: json.encode(
          {'isFavorite': isFavorite},
        ),
      );
      if (res.statusCode >= 400) {
        _setFavValue(oldStatus!);
        throw HttpException('Error');
      }
    } catch (error) {
      print(error);
      _setFavValue(oldStatus!);
      rethrow;
    }
  }
}
