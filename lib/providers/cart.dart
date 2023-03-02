import 'package:flutter/material.dart';

class CardItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CardItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CardItem> _items = {};

  Map<String, CardItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingCardItem) => CardItem(
              id: existingCardItem.id,
              title: existingCardItem.title,
              quantity: existingCardItem.quantity + 1,
              price: existingCardItem.price));
    } else {
      _items.putIfAbsent(
        productId,
        () => CardItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: 1,
            price: price),
      );
    }
    notifyListeners();
  }

  void removeITem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existingCardItem) => CardItem(
                id: existingCardItem.id,
                title: existingCardItem.title,
                quantity: existingCardItem.quantity - 1,
                price: existingCardItem.price,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
