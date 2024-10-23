import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../../helpers/api_helper.dart';
import '../../widgets/common/popup_widget.dart';

class DrawerAuthButton extends StatelessWidget {
  const DrawerAuthButton({
    Key? key,
    required this.authData,
  }) : super(key: key);

  final Auth authData;

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;

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
          await ApiHelper.deleteUserAccount(client, authData);
          authData.logout();
          Provider.of<Filter>(context, listen: false).resetFilters();
          await popupDialog(context, [], 'Bruker slettet',
              'Brukeren din og alle data er nå slettet.');
        } catch (error) {
          await popupDialog(context, [], 'Det oppsto en feil',
              'Det oppsto en feil ved sletting av brukeren din. Kontakt Ølmonopolet for å slette brukeren.');
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

    return authData.isAuth
        ? ListTile(
            trailing: const Icon(Icons.exit_to_app),
            title: const Text('Logg ut'),
            onTap: () {
              List<Widget> buttons = [deleteUserButton, confirmLogoutButton];
              popupDialog(
                context,
                buttons,
                'Logg ut',
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
          );
  }
}
