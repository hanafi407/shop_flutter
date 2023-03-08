import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../provider/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  const OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$ ${widget.order.amount}'),
            subtitle: Text(
                DateFormat('dd/MM/yyyy   hh:mm').format(widget.order.date)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              // decoration:
              //     BoxDecoration(border: Border.all(color: Colors.black)),
              margin: EdgeInsets.only(bottom: 5),
              height: min(widget.order.product.length * 20.0 + 10, 100),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: ListView(
                children: widget.order.product
                    .map((pro) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${pro.title}: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${pro.quantity} x \$${pro.price}',
                                style: TextStyle(fontSize: 18))
                          ],
                        ))
                    .toList(),
              ),
            )
        ],
      ),
    );
  }
}
