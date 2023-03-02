import 'dart:convert';
import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodId) => prodId.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetproducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final urlString =
        'https://flutter-update-4564e-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    final url = Uri.parse(urlString);
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      final urlStringFavorite =
          'https://flutter-update-4564e-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final urlFavorite = Uri.parse(urlStringFavorite);

      final favoriteResponse = await http.get(urlFavorite);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedproducts = [];
      extractedData.forEach((prodId, prod) {
        loadedproducts.add(
          Product(
            id: prodId,
            title: prod['title'],
            description: prod['description'],
            price: prod['price'],
            imageUrl: prod['imageURL'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        );
      });
      _items = loadedproducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final urlString =
        'https://flutter-update-4564e-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    //const urlString = 'https://flutter-.com';

    final url = Uri.parse(urlString);
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageURL': product.imageUrl,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProducts(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final urlString =
          'https://flutter-update-4564e-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      final url = Uri.parse(urlString);
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageURL': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final urlString =
        'https://flutter-update-4564e-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final url = Uri.parse(urlString);
    final existingIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingIndex];
    _items.removeAt(existingIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
