import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../providers/auth.dart';
import '../../helpers/app_launcher.dart';
import '../../screens/about_screen.dart';
import '../../widgets/drawer/drawer_auth_button.dart';
import '../../widgets/drawer/drawer_avatar_image.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late AdaptiveThemeMode? _themeMode = AdaptiveThemeMode.light;
  void _getTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _themeMode = savedThemeMode;
    });
  }

  @override
  void initState() {
    _getTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context);

    return Drawer(
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 70),
          if (authData.isAuth)
            Column(
              children: [
                DrawerAvatarImage(authData: authData),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  authData.userName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          const Divider(),
          ListTile(
            trailing: Icon(
              _themeMode == AdaptiveThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            title: Text(
              _themeMode == AdaptiveThemeMode.dark ? 'Lys modus' : 'Mørk modus',
            ),
            onTap: () {
              if (_themeMode == AdaptiveThemeMode.dark) {
                _themeMode = AdaptiveThemeMode.light;
                AdaptiveTheme.of(context).setLight();
              } else {
                _themeMode = AdaptiveThemeMode.dark;
                AdaptiveTheme.of(context).setDark();
              }
            },
          ),
          const Divider(),
          ListTile(
            trailing: const Icon(Icons.facebook),
            title: const Text('Følg på Facebook'),
            onTap: () {
              AppLauncher.launchFacebook();
            },
          ),
          const Divider(),
          ListTile(
            trailing: const Icon(Icons.email),
            title: const Text('Gi tilbakemelding'),
            onTap: () {
              launchUrl(Uri.parse('mailto:post@olmonopolet.app'));
            },
          ),
          const Divider(),
          ListTile(
            trailing: const Icon(Icons.info),
            title: const Text('Om'),
            onTap: () {
              pushScreen(
                context,
                settings: RouteSettings(name: AboutScreen.routeName),
                screen: AboutScreen(),
              );
            },
          ),
          const Divider(),
          DrawerAuthButton(
            authData: authData,
          ),
          // const Divider(),
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.all(15.0),
          //     child: Align(
          //       alignment: Alignment.bottomCenter,
          //       child: Image.asset(
          //         'assets/images/powered_by_untappd.png',
          //         width: 100,
          //         color: Theme.of(context).colorScheme.onSurface,
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
