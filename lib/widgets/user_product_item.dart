import 'package:flutter/material.dart';
import '../screens/edit_product_screen.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class UserprorcutItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserprorcutItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffoldMesenger = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(children: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: id);
            },
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).primaryColor,
            ),
          ),
          IconButton(
            onPressed: () async {
              try {
                await Provider.of<Products>(context, listen: false)
                    .deleteProduct(id);
              } catch (error) {
                scaffoldMesenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Deleting Failed',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          )
        ]),
      ),
    );
  }
}
