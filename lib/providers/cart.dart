import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../helpers/db_helper.dart';
import '../helpers/api_helper.dart';
import '../models/product.dart';
import '../models/store.dart';

class CartItem {
  final Product product;
  final int quantity;
  bool inStock;

  CartItem({
    required this.product,
    required this.quantity,
    this.inStock = true,
  });
}

class Cart with ChangeNotifier {
  late String _apiToken;
  late http.Client _client;

  void update(String token, http.Client client) {
    _apiToken = token;
    _client = client;
  }

  Map<int, CartItem> _items = {};
  List<int> itemsInStock = [];
  List<String> cartSelectedStores = [];
  String cartStoreId = '';
  bool useOverviewStoreSelection = true;
  bool greyNoStock = false;
  bool hideNoStock = false;
  String cartSortIndex = 'Ingen sortering';

  Map<int, CartItem> get items {
    return {..._items};
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(int productId, Product product) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
    checkCartStockStatus();
    sortCart();
    updateDb(productId);
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
    checkCartStockStatus();
    updateDb(productId);
  }

  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
      checkCartStockStatus();
    }
    notifyListeners();
    updateDb(productId);
  }

  void clear() {
    _items = {};
    itemsInStock = [];
    notifyListeners();
    DBHelper.clear('cart');
  }

  void updateDb(int productId) {
    if (_items.containsKey(productId)) {
      DBHelper.insert(
        'cart',
        {
          'id': _items[productId]!.product.id,
          'name': _items[productId]!.product.name,
          'style': _items[productId]!.product.style,
          'price': _items[productId]!.product.price,
          'volume': _items[productId]!.product.volume,
          'pricePerVolume': _items[productId]!.product.pricePerVolume,
          'stock': _items[productId]!.product.stock,
          'rating': _items[productId]!.product.rating,
          'checkins': _items[productId]!.product.checkins,
          'abv': _items[productId]!.product.abv,
          'imageUrl': _items[productId]!.product.imageUrl,
          'userRating': _items[productId]!.product.userRating,
          'userWishlisted':
              (_items[productId]!.product.userWishlisted!) ? 1 : 0,
          'vmpUrl': _items[productId]!.product.vmpUrl,
          'untappdUrl': _items[productId]!.product.untappdUrl,
          'untappdId': _items[productId]!.product.untappdId,
          'country': _items[productId]!.product.country,
          'quantity': _items[productId]!.quantity,
        },
      );
    } else {
      DBHelper.removeItem('cart', productId);
    }
  }

  Future<void> fetchAndSetCart() async {
    if (_items.isEmpty) {
      final dataList = await DBHelper.getData('cart');
      for (var item in dataList) {
        _items.putIfAbsent(
          item['id'],
          () => CartItem(
            product: Product(
              id: item['id'],
              name: item['name'],
              style: item['style'],
              price: item['price'],
              volume: item['volume'],
              pricePerVolume: item['pricePerVolume'],
              stock: item['stock'],
              rating: item['rating'],
              checkins: item['checkins'],
              abv: item['abv'],
              imageUrl: item['imageUrl'],
              userRating: item['userRating'],
              userWishlisted: (item['userWishlisted'] == 1) ? true : false,
              vmpUrl: item['vmpUrl'],
              untappdUrl: item['untappdUrl'],
              untappdId: item['untappdId'],
              country: item['country'],
            ),
            quantity: item['quantity'],
          ),
        );
      }
      final prefs = await SharedPreferences.getInstance();
      cartStoreId = prefs.getString('cartStoreId') ?? '';
      cartSortIndex = prefs.getString('cartSortIndex') ?? 'Ingen sortering';
      cartSelectedStores = prefs.getStringList('cartSelectedStores') ?? [];
      useOverviewStoreSelection =
          prefs.getBool('useOverviewStoreSelection') ?? true;
      greyNoStock = prefs.getBool('greyNoStock') ?? false;
      hideNoStock = prefs.getBool('hideNoStock') ?? false;
      notifyListeners();

      if (greyNoStock || hideNoStock) {
        checkCartStockStatus();
      }
      updateCartItemsData();
      sortCart();
    }
  }

  Future<void> updateCartItemsData() async {
    if (_items.isNotEmpty) {
      final productIds = _items.keys.toList().join(',');
      final updatedProducts =
          await ApiHelper.getProductsData(_client, productIds, _apiToken);
      updatedProducts.forEach((product) {
        _items[product.id] = CartItem(
          product: Product(
              id: product.id,
              name: product.name,
              style: product.style,
              price: product.price,
              volume: product.volume,
              pricePerVolume: product.pricePerVolume,
              stock: product.stock,
              rating: product.rating,
              checkins: product.checkins,
              abv: product.abv,
              imageUrl: product.imageUrl,
              userRating: product.userRating,
              userWishlisted: product.userWishlisted,
              vmpUrl: product.vmpUrl,
              untappdUrl: product.untappdUrl,
              untappdId: product.untappdId,
              country: product.country),
          quantity: _items[product.id]!.quantity,
          inStock: _items[product.id]!.inStock,
        );
        updateDb(product.id);
      });
      notifyListeners();
    }
  }

  void saveCartSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cartStoreId', cartStoreId);
    prefs.setString('cartSortIndex', cartSortIndex);
    prefs.setStringList('cartSelectedStores', cartSelectedStores);
    prefs.setBool('useOverviewStoreSelection', useOverviewStoreSelection);
    prefs.setBool('greyNoStock', greyNoStock);
    prefs.setBool('hideNoStock', hideNoStock);
    prefs.setString('cartSortIndex', cartSortIndex);
    notifyListeners();
  }

  Future<void> checkCartStockStatus() async {
    if (cartStoreId.isNotEmpty) {
      String cartItemIds = '';
      _items.forEach((key, value) {
        if (cartItemIds.isNotEmpty) {
          cartItemIds += ',';
        }
        cartItemIds += value.product.id.toString();
      });
      var response =
          await ApiHelper.checkStock(_client, cartItemIds, cartStoreId);
      itemsInStock = [];
      response.forEach((element) {
        itemsInStock.add(element['vmp_id']);
      });
      _items.forEach((key, value) {
        if (itemsInStock.contains(value.product.id)) {
          value.inStock = true;
        } else {
          value.inStock = false;
        }
      });
      notifyListeners();
    }
  }

  void setCartStore(List<Store> storeList) {
    if (cartSelectedStores.isEmpty) {
      cartStoreId = '';
    } else {
      String temporaryStores = '';
      cartSelectedStores.forEach((storeName) {
        if (temporaryStores.isNotEmpty) {
          temporaryStores += ',';
        }
        temporaryStores +=
            storeList.firstWhere((element) => element.name == storeName).id;
      });
      cartStoreId = temporaryStores;
    }
    notifyListeners();
    saveCartSettings();
  }

  void sortCart() {
    final sorted = _items.entries.toList();
    if (cartSortIndex == 'Alkohol - Høy til lav') {
      sorted
        ..sort(
          (a, b) {
            int result;
            if (a.value.product.abv == null) {
              result = 1;
            } else if (b.value.product.abv == null) {
              result = -1;
            } else {
              result = b.value.product.abv!.compareTo(a.value.product.abv!);
            }
            return result;
          },
        );
    } else if (cartSortIndex == 'Alkohol - Lav til høy') {
      sorted
        ..sort(
          (a, b) {
            int result;
            if (a.value.product.abv == null) {
              result = 1;
            } else if (b.value.product.abv == null) {
              result = -1;
            } else {
              result = a.value.product.abv!.compareTo(b.value.product.abv!);
            }
            return result;
          },
        );
    } else if (cartSortIndex == 'Din rating - Høy til lav') {
      sorted
        ..sort(
          (a, b) {
            int result;
            if (a.value.product.userRating == null) {
              result = 1;
            } else if (b.value.product.userRating == null) {
              result = -1;
            } else {
              result = b.value.product.userRating!
                  .compareTo(a.value.product.userRating!);
            }
            return result;
          },
        );
    } else if (cartSortIndex == 'Din rating - Lav til høy') {
      sorted
        ..sort(
          (a, b) {
            int result;
            if (a.value.product.userRating == null) {
              result = 1;
            } else if (b.value.product.userRating == null) {
              result = -1;
            } else {
              result = a.value.product.userRating!
                  .compareTo(b.value.product.userRating!);
            }
            return result;
          },
        );
    } else if (cartSortIndex == 'Global rating - Høy til lav') {
      sorted
        ..sort(
          (a, b) {
            int result;
            if (a.value.product.rating == null) {
              result = 1;
            } else if (b.value.product.rating == null) {
              result = -1;
            } else {
              result =
                  b.value.product.rating!.compareTo(a.value.product.rating!);
            }
            return result;
          },
        );
    } else if (cartSortIndex == 'Global rating - Lav til høy') {
      sorted
        ..sort(
          (a, b) {
            int result;
            if (a.value.product.rating == null) {
              result = 1;
            } else if (b.value.product.rating == null) {
              result = -1;
            } else {
              result =
                  a.value.product.rating!.compareTo(b.value.product.rating!);
            }
            return result;
          },
        );
    } else if (cartSortIndex == 'Navn - A til Å') {
      sorted
        ..sort(
          (a, b) => a.value.product.name.compareTo(b.value.product.name),
        );
    } else if (cartSortIndex == 'Navn - Å til A') {
      sorted
        ..sort(
          (a, b) => b.value.product.name.compareTo(a.value.product.name),
        );
    } else if (cartSortIndex == 'Pris - Høy til lav') {
      sorted
        ..sort(
          (a, b) => b.value.product.price.compareTo(a.value.product.price),
        );
    } else if (cartSortIndex == 'Pris - Lav til høy') {
      sorted
        ..sort(
          (a, b) => a.value.product.price.compareTo(b.value.product.price),
        );
    } else if (cartSortIndex == 'Pris per liter - Høy til lav') {
      sorted
        ..sort(
          (a, b) => b.value.product.pricePerVolume!
              .compareTo(a.value.product.pricePerVolume!),
        );
    } else if (cartSortIndex == 'Pris per liter - Lav til høy') {
      sorted
        ..sort(
          (a, b) => a.value.product.pricePerVolume!
              .compareTo(b.value.product.pricePerVolume!),
        );
    }
    _items = Map<int, CartItem>.fromEntries(sorted);
    saveCartSettings();
  }
}
