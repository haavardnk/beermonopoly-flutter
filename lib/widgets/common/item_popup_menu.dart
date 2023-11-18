import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../helpers/untappd_helper.dart';
import '../../helpers/app_launcher.dart';
import '../../models/product.dart';
import '../../providers/auth.dart';
import '../../providers/http_client.dart';

Future<String?> showPopupMenu(BuildContext context, Auth auth, bool wishlisted,
    Offset tapPosition, RenderBox overlay, Product product) async {
  final apiToken = auth.apiToken;
  final untappdToken = auth.untappdToken;
  final client = Provider.of<HttpClient>(context).untappdClient;
  var value = await showMenu<String>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
    position:
        RelativeRect.fromSize(tapPosition & const Size(40, 40), overlay.size),
    items: <PopupMenuEntry<String>>[
      if (wishlisted == false && auth.isAuth)
        PopupMenuItem(
          value: 'addWishlist',
          child: Row(
            children: <Widget>[
              Icon(Icons.playlist_add),
              Text(" Legg i Untappd ønskeliste"),
            ],
          ),
        ),
      if (wishlisted == true && auth.isAuth)
        PopupMenuItem(
          value: 'removeWishlist',
          child: Row(
            children: <Widget>[
              Icon(Icons.playlist_remove),
              Text(" Fjern fra Untappd ønskeliste"),
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
  if (value == "addWishlist") {
    var success = await UntappdHelper.addToWishlist(
        client, apiToken, untappdToken, product);
    if (success) {
      return 'wishlistAdded';
    }
  }
  if (value == "removeWishlist") {
    var success = await UntappdHelper.removeFromWishlist(
        client, apiToken, untappdToken, product);
    if (success) {
      return 'wishlistRemoved';
    }
  }
  if (value == "untappd") {
    AppLauncher.launchUntappd(product);
  }
  if (value == "vinmonopolet") {
    launchUrl(Uri.parse(product.vmpUrl!));
  }
  return null;
}
