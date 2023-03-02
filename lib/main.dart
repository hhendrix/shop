import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import '../providers/auth.dart';

import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products.screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/splash_screen.dart';
import './helpers/custom_route.dart';

//test@test.com
//password

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products('', '', []),
          update: (context, auth, previousProducts) => Products(
              auth.token ?? '',
              auth.userId ?? '',
              (previousProducts != null || previousProducts?.items == null)
                  ? []
                  : previousProducts!.items),
        ),
        ChangeNotifierProvider(
          create: (cxt) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders('', '', []),
          update: (context, auth, previousOrders) => Orders(
            auth.token ?? '',
            auth.userId ?? '',
            (previousOrders != null || previousOrders?.orders == null)
                ? []
                : previousOrders!.orders,
          ),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'My Shop',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder(),
                },
              )),
          home: auth.isAuth
              ? ProductOverViewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: ((context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
                ),
          routes: {
            ProductDetailScreen.routedName: ((context) =>
                ProductDetailScreen()),
            CartScreen.routeName: (context) => CartScreen(),
            OrderScreen.routedName: (context) => OrderScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
