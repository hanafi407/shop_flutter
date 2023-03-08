import 'package:flutter/material.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final DateTime date;
  final List<CartItem> product;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.date,
      required this.product});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrder() async {
    var url = Uri.https(
        'hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/orders.json');

    final res = await http.get(url);

    List<OrderItem> loadedOrders = [];

    final extractedData = json.decode(res.body) as Map<String, dynamic>?;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((key, orderData) {
      loadedOrders.add(OrderItem(
          id: key,
          amount: orderData['amount'],
          date: DateTime.parse(orderData['date']),
          product: (orderData['product'] as List<dynamic>)
              .map(
                (prod) => CartItem(
                    id: prod['id'],
                    price: prod['price'],
                    quantity: prod['quantity'],
                    title: prod['title']),
              )
              .toList()));
    });
    _orders = loadedOrders.reversed.toList();
    print(_orders);
    notifyListeners();
  }

  Future<void> addOrders(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    var url = Uri.https(
        'hanafi-flutter-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/orders.json');

    var res = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'date': timeStamp.toIso8601String(),
          'product': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList(),
        },
      ),
    );

    _orders.insert(
      0,
      OrderItem(
          id: json.decode(res.body)['name'],
          amount: total,
          date: timeStamp,
          product: cartProducts),
    );
    notifyListeners();
  }
}
