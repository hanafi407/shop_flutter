import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_flutter/screens/product_detail_screen.dart';
import './provider/products.dart';
import './provider/cart.dart';
import './provider/orders.dart';
import './screens/product_overview_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './provider/auth.dart';
import './screens/splash_screen.dart';
import './helpers/custom_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print('build main.dart');
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<Auth>(create: (ctx) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products(),
            update: (ctx, auth, products) => products == null
                ? (products!
                  ..setToken = auth.token
                  ..itemsEmpty)
                : (products
                  ..setToken = auth.token
                  ..items)
              ..setUserId = auth.userId,
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders(),
            update: (ctx, auth, order) => order == null
                ? (order!
                  ..setToken = auth.token
                  ..setUserId = auth.userId
                  ..orderEmpty)
                : (order
                  ..setToken = auth.token
                  ..setUserId = auth.userId
                  ..orders),
          ),
          ChangeNotifierProvider<Cart>(create: (ctx) => Cart()),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                fontFamily: 'Lato',
                primaryColor: Colors.purple,
                accentColor: Colors.deepOrange,
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder(),
                })
                // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                //     .copyWith(secondary: Colors.deepOrange)
                ),
            routes: {
              ProductOverviewScreen.routeName: (context) =>
                  ProductOverviewScreen(),
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductScreen.routeName: (context) => UserProductScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.autoLogin(),
                    builder: (context, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
          ),
        ));
  }
}
