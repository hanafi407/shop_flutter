import 'dart:ffi';

import 'package:flutter/material.dart';
import '../provider/product.dart';
import 'package:provider/provider.dart';
import '../provider/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _pricesFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _initValues = {
    'title': '',
    'price': '',
    'imageUrl': '',
    'description': '',
  };
  var _isInit = true;
  var _isLoading = false;
  var _editedProduct = Product(
    productId: '',
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productid = ModalRoute.of(context)?.settings.arguments;
      if (productid != null) {
        _editedProduct =
            Provider.of<Products>(context).findById(productid as String);

        _initValues = {
          'title': _editedProduct.title!,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description!,
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': ''
        };
        _imageUrlController.text = _editedProduct.imageUrl!;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateUrlImage);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateUrlImage);
    _pricesFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _updateUrlImage() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    print(isValid);

    if (!(isValid!)) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.productId!.isNotEmpty) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.productId!, _editedProduct);

      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
        Navigator.of(context).pop();
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
      // finally {
      //   print('finally');
      //   setState(() {
      //     _isLoading = false;
      //   });

      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build ulang edit_product_screen.dart');
    return Scaffold(
      appBar: AppBar(
        title: Text('User Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.all(16),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(
                          label: Text('Title'),
                        ),
                        validator: (value) {
                          // value = value as String;
                          if (value!.isEmpty) {
                            return 'Please input title';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_pricesFocusNode),
                        onSaved: (value) {
                          _editedProduct = Product(
                              productId: _editedProduct.productId,
                              title: value as String, //masukan nilai disini
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(label: Text('Price')),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please input price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please input invalid number';
                          }

                          if (double.parse(value) <= 0) {
                            return 'Please input number greater than 0';
                          }

                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _pricesFocusNode,
                        onFieldSubmitted: (_) {
                          return FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              productId: _editedProduct.productId,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: double.parse(value!),
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(label: Text('Description')),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please input description!';
                          }

                          if (value.length < 10) {
                            return 'Please input character more than 10 character';
                          }
                          return null;
                        },
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onSaved: (value) {
                          _editedProduct = Product(
                              productId: _editedProduct.productId,
                              title: _editedProduct.title,
                              description: value as String,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite);
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            )),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter URL')
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Image URL',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please input image url!';
                                }

                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'please initiate with http/https';
                                }

                                if (!value.endsWith('.jpg') &&
                                    !value.endsWith('.png') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please input invalid extension(.jgp,.png,.jpeg)';
                                }

                                return null;
                              },
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) => setState(() {}),
                              onSaved: (value) {
                                _editedProduct = Product(
                                    productId: _editedProduct.productId,
                                    title: _editedProduct.title,
                                    description: _editedProduct.description,
                                    price: _editedProduct.price,
                                    imageUrl: value as String,
                                    isFavorite: _editedProduct.isFavorite);
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
