import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  State<EditProductScreen> createState() => _EditProductScreen();
}

class _EditProductScreen extends State<EditProductScreen> {
  final _proceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedproduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageURL': '',
  };

  var _isInt = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInt) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        _editedproduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedproduct.title,
          'description': _editedproduct.description,
          'price': _editedproduct.price.toString(),
          'imageURL': '',
        };
        _imageUrlController.text = _editedproduct.imageUrl;
      }
    }
    _isInt = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _descriptionFocusNode.dispose();
    _proceFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpge'))) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    if (_form.currentState != null) {
      final isValid = _form.currentState!.validate();
      if (!isValid) {
        return;
      }
      _form.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      if (_editedproduct.id != '') {
        await Provider.of<Products>(context, listen: false).updateProducts(
          _editedproduct.id,
          _editedproduct,
        );
      } else {
        try {
          await Provider.of<Products>(context, listen: false)
              .addProduct(_editedproduct);
        } catch (error) {
          print("Error ASYNC");
          await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: const Text('An error ocurred!'),
                    content: Text('Someting went wrong.'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text('Okay'))
                    ],
                  ));
        }
        // finally {
        //   setState(() {
        //     _isLoading = false;
        //   });
        //   Navigator.of(context).pop();
        // }
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(children: [
                  TextFormField(
                    initialValue: _initValues['title'],
                    decoration: InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_proceFocusNode);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a value';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _editedproduct = Product(
                          id: _editedproduct.id,
                          title: value,
                          description: _editedproduct.description,
                          price: _editedproduct.price,
                          imageUrl: _editedproduct.imageUrl,
                          isFavorite: _editedproduct.isFavorite,
                        );
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _proceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter Valis Number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a numebr greater than zero';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _editedproduct = Product(
                          id: _editedproduct.id,
                          title: _editedproduct.title,
                          description: _editedproduct.description,
                          price: double.parse(value),
                          imageUrl: _editedproduct.imageUrl,
                          isFavorite: _editedproduct.isFavorite,
                        );
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['description'],
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Description';
                      }
                      if (value.length < 10) {
                        return 'Should be at least 10 characteres long';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _editedproduct = Product(
                          id: _editedproduct.id,
                          title: _editedproduct.title,
                          description: value,
                          price: _editedproduct.price,
                          imageUrl: _editedproduct.imageUrl,
                          isFavorite: _editedproduct.isFavorite,
                        );
                      }
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        margin: EdgeInsets.only(top: 8, right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        )),
                        child: _imageUrlController.text.isEmpty
                            ? Text('Enter a URL!')
                            : FittedBox(
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a image URL';
                            }

                            if (!value.startsWith('http') &&
                                !value.startsWith('https')) {
                              return 'Please enter a valid url';
                            }

                            if (!value.endsWith('.png') &&
                                !value.endsWith('.jpg') &&
                                !value.endsWith('.jpge')) {
                              return 'Please enter a valid image url';
                            }

                            return null;
                          },
                          onEditingComplete: () {
                            setState(() {});
                          },
                          onSaved: (value) {
                            if (value != null) {
                              _editedproduct = Product(
                                id: _editedproduct.id,
                                title: _editedproduct.title,
                                description: _editedproduct.description,
                                price: _editedproduct.price,
                                imageUrl: value,
                                isFavorite: _editedproduct.isFavorite,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
    );
  }
}
