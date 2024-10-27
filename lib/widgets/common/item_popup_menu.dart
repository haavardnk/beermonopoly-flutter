import 'package:beermonopoly/helpers/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import '../../helpers/app_launcher.dart';
import '../../models/product.dart';
import '../../providers/auth.dart';
import '../../providers/http_client.dart';

Future<String?> showPopupMenu(BuildContext context, Auth auth, bool tasted,
    RelativeRect position, Product product) async {
  final apiToken = auth.apiToken;
  final client = Provider.of<HttpClient>(context, listen: false).apiClient;
  final cart = Provider.of<Cart>(context, listen: false);
  var value = await showMenu<String>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
    position: position,
    items: <PopupMenuEntry<String>>[
      if (tasted == false && auth.isAuth)
        PopupMenuItem(
          value: 'addTasted',
          child: Row(
            children: <Widget>[
              Icon(Icons.check_rounded),
              Text(" Merk som smakt"),
            ],
          ),
        ),
      if (tasted == true && auth.isAuth)
        PopupMenuItem(
          value: 'removeTasted',
          child: Row(
            children: <Widget>[
              Icon(Icons.close_rounded),
              Text(" Fjern smakt"),
            ],
          ),
        ),
      if (!cart.items.keys.contains(product.id))
        PopupMenuItem(
          value: 'addToCart',
          child: Row(
            children: <Widget>[
              Icon(Icons.check_rounded),
              Text(" Legg i handleliste"),
            ],
          ),
        ),
      if (cart.items.keys.contains(product.id))
        PopupMenuItem(
          value: 'removeFromCart',
          child: Row(
            children: <Widget>[
              Icon(Icons.close_rounded),
              Text(" Fjern fra handleliste"),
            ],
          ),
        ),
      if (product.untappdUrl != null)
        PopupMenuItem(
          value: 'untappd',
          child: Row(
            children: <Widget>[
              Icon(Icons.open_in_browser),
              Text(" Åpne i Untappd"),
            ],
          ),
        ),
      if (product.vmpUrl != null)
        PopupMenuItem(
          value: 'vinmonopolet',
          child: Row(
            children: <Widget>[
              Icon(Icons.open_in_browser),
              Text(" Åpne i Vinmonopolet"),
            ],
          ),
        )
    ],
    context: context,
  );
  if (value == "addTasted") {
    var success = await ApiHelper.addTasted(product.id, client, apiToken);
    if (success) {
      return 'addedTasted';
    }
  }
  if (value == "removeTasted") {
    var success = await ApiHelper.removeTasted(product.id, client, apiToken);
    if (success) {
      return 'removedTasted';
    }
  }
  if (value == "addToCart") {
    cart.addItem(product.id, product);
    cart.updateCartItemsData();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Lagt til i handlelisten',
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  if (value == "removeFromCart") {
    cart.removeItem(product.id);
    cart.updateCartItemsData();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fjernet fra handlelisten',
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  if (value == "untappd") {
    AppLauncher.launchUntappd(product);
  }
  if (value == "vinmonopolet") {
    launchUrl(Uri.parse(product.vmpUrl!));
  }
  return null;
}
