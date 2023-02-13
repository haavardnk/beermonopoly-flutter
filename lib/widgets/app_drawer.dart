import 'package:beermonopoly/helpers/api_helper.dart';
import 'package:beermonopoly/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../providers/auth.dart';
import '../providers/filter.dart';
import '../helpers/app_launcher.dart';
import 'popup_widget.dart';

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

    Widget confirmLogoutButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pushReplacementNamed('/');
        authData.logout();
        Provider.of<Filter>(context, listen: false).resetFilters();
      },
      child: Text(
        'Logg ut',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    Widget confirmDeleteUserButton = ElevatedButton(
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop();
        try {
          await ApiHelper.deleteUserAccount(authData);
          authData.logout();
          Provider.of<Filter>(context, listen: false).resetFilters();
          await popupDialog(context, [], 'Bruker slettet',
              'Brukeren din og alle data er nå slettet.');
        } catch (error) {
          await popupDialog(context, [], 'Det oppsto en feil',
              'Det oppsto en feil ved sletting av brukeren din. Kontakt utvikler for å slette brukeren.');
        }
      },
      child: const Text(
        'Slett bruker',
      ),
    );

    Widget deleteUserButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        popupDialog(
          context,
          [confirmDeleteUserButton],
          'Slette bruker',
          'Er du sikker på at du vil slette brukeren din på Ølmonopolet og alle data?',
        );
      },
      child: Text(
        'Slett bruker',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    return Drawer(
      elevation: 20,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 70),
          if (authData.isAuth)
            Column(
              children: [
                CachedNetworkImage(
                  imageUrl: authData.userAvatarUrl,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundImage: imageProvider,
                    backgroundColor: Colors.transparent,
                    radius: 65,
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
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
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: AboutScreen.routeName),
                screen: AboutScreen(),
                withNavBar: true,
              );
            },
          ),
          const Divider(),
          authData.isAuth
              ? ListTile(
                  trailing: const Icon(Icons.exit_to_app),
                  title: const Text('Logg ut'),
                  onTap: () {
                    List<Widget> buttons = [
                      deleteUserButton,
                      confirmLogoutButton
                    ];
                    popupDialog(
                      context,
                      buttons,
                      'Logge ut',
                      'Er du sikker på at du vil logge ut?',
                    );
                  },
                )
              : ListTile(
                  trailing: const Icon(Icons.exit_to_app),
                  title: const Text('Logg inn'),
                  onTap: () {
                    authData.skipLogin(false);
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/powered_by_untappd.png',
                  width: 100,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
