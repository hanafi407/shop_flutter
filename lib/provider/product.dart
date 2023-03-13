import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String? productId;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool? isFavorite;

  Product({
    required this.productId,
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

  Future<void> togleFavoriteStatus(String? token, String? userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite!;
    notifyListeners();
    final url = Uri.parse(
        'https://hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$productId.json?auth=$token');
    try {
      var res = await http.put(
        url,
        body: json.encode(
          isFavorite,
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
