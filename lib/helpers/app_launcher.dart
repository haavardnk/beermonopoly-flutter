import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';

class AppLauncher {
  static Future<void> launchUntappd(Product product) async {
    var untappdInstalled = await LaunchApp.isAppInstalled(
      iosUrlScheme: 'untappd://',
      androidPackageName: 'com.untappdllc.app',
    );
    print(untappdInstalled);
    if (untappdInstalled == true || untappdInstalled == 1) {
      launch('untappd://beer/${product.untappdId}');
    } else {
      launch(product.untappdUrl!);
    }
  }
}
