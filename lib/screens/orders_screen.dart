import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import 'package:provider/provider.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routedName = '/orders';

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    print('Orders Build');
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: ((context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              return Center(
                child: Text('An error ocurred!'),
              );
            } else {
              return Consumer<Orders>(
                builder: ((context, orderData, child) => ListView.builder(
                      itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                      itemCount: orderData.orders.length,
                    )),
              );
            }
          }
        }),
      ),
      drawer: AppDrawer(),
    );
  }
}
