import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-product';
  const UserProductScreen({super.key});

  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context, listen: false);
    print('rebuilding UserProductScreen...');
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Product'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _refreshProduct(context),
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () => _refreshProduct(context),
                  child: Consumer<Products>(
                    builder: (context, productsData, _) => Container(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        itemBuilder: (_, index) {
                          return Column(
                            children: [
                              UserProductItem(
                                id: productsData.items[index].productId!,
                                imageUrl: productsData.items[index].imageUrl!,
                                title: productsData.items[index].title!,
                              ),
                              Divider()
                            ],
                          );
                        },
                        itemCount: productsData.items.length,
                      ),
                    ),
                  )),
        ));
  }
}
