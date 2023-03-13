import 'dart:io';

import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product>? _items = [];
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'Warm and cozy - exactly what you need for the winter.',
  //     price: 19.99,
  //     imageUrl:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 49.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   )

  String? _token;
  // Products(this.token);

  set setToken(String? token) {
    _token = token;
  }

  String? _userId;

  set setUserId(String? userId) {
    _userId = userId;
  }

  var _showFavoriteOnly = false;

  List<Products> get itemsEmpty {
    return [];
  }

  List<Product> get items {
    if (_showFavoriteOnly) {
      return _items!.where((item) => item.isFavorite!).toList();
    }
    return [..._items!];
  }

  List<Product> get favoriteItems {
    return _items!.where((item) => item.isFavorite!).toList();
  }

  Product findById(String id) {
    return _items!.firstWhere((item) => item.productId == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    String filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';

    var url = Uri.parse(
        'https://hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_token&$filterString');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;

      if (extractedData == null) {
        return;
      }

      url = Uri.parse(
          'https://hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$_userId.json?auth=$_token');

      final resIsFavorite = await http.get(url);
      final favoriteData = json.decode(resIsFavorite.body);

      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(
          Product(
              productId: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[prodId] ?? false),
        );
      });

      _items = loadedProduct;
      print('Producs.fetchAndSetProducts()');
      notifyListeners();
    } catch (error) {
      print('products $error');
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        'https://hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_token');
    try {
      final res = await http.post(
        url,
        body: json.encode({
          'creatorId': _userId,
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
        }),
      );

      print(json.decode(res.body));

      final newProduct = Product(
        productId: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items!.add(newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items!.indexWhere((prod) => prod.productId == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$_token');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
          }));
      _items![prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$_token');
    final existingProductIndex =
        _items!.indexWhere((element) => element.productId == id);
    var existingProduct = _items?[existingProductIndex];
    _items!.removeAt(existingProductIndex);
    notifyListeners();
    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      _items!.insert(existingProductIndex, existingProduct!);
      notifyListeners();
      throw HttpException('Could not delete delete product');
    }
    existingProduct = null;
  }

  // void showFavoriteOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }
}
