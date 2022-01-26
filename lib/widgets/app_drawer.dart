import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import '../providers/auth.dart';

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
      elevation: 20,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 70),
          if (authData.isAuth)
            Column(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundImage: NetworkImage(authData.userAvatarUrl),
                  backgroundColor: Colors.transparent,
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
          authData.isAuth
              ? ListTile(
                  trailing: const Icon(Icons.exit_to_app),
                  title: const Text('Logg ut'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                    authData.logout();
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
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
