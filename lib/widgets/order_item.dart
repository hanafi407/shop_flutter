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
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.product.length * 20.0 + 147, 300) : 97,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$ ${widget.order.amount.toStringAsFixed(2)}'),
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
            AnimatedContainer(
              // decoration: BoxDecoration(border: Border.all(width: 1)),
              duration: Duration(milliseconds: 300),
              // curve: Curves.easeIn,
              // decoration:
              //     BoxDecoration(border: Border.all(color: Colors.black)),
              margin: EdgeInsets.only(bottom: 5),
              height:
                  _expanded ? min(widget.order.product.length * 30.0, 100) : 0,
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
      ),
    );
  }
}
