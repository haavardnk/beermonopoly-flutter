import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../providers/auth.dart';
import 'auth_registration_screen.dart';
import 'auth_login_screen.dart';

class AuthLandingScreen extends StatefulWidget {
  const AuthLandingScreen({Key? key}) : super(key: key);
  static const routeName = '/auth';

  @override
  State<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends State<AuthLandingScreen> {
  final loading = false;

  @override
  Widget build(BuildContext context) {
    final _mediaQueryData = MediaQuery.of(context);
    final _authData = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => _authData.skipLogin(true),
            child: Text(
              'Hopp over',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          _mediaQueryData.size.width * 0.10,
          30,
          _mediaQueryData.size.width * 0.10,
          100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Image.asset('assets/images/logo_transparent.png', height: 300),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  child: const Text(
                    'Logg inn',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    pushScreen(
                      context,
                      screen: AuthLoginScreen(),
                    );
                  },
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    pushScreen(
                      context,
                      screen: AuthRegistrationScreen(),
                    );
                  },
                  child: Text(
                    'Registrer',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: Divider(),
                  ),
                  Text("    eller    "),
                  Expanded(
                    child: Divider(),
                  ),
                ]),
                SizedBox(height: 15),
                Container(
                  height: 40,
                  child: SignInButton(
                    Buttons.apple,
                    text: "Fortsett med Apple",
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      try {
                        await _authData.authenticateApple();
                      } catch (error) {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title: const Text('Feil'),
                            content: const Text(
                                'Det har oppstått en feil med innloggingen. '
                                'Sjekk internett tilkoblingen din eller prøv igjen senere.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: const Text(
                                  'OK',
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 40,
                  child: SignInButton(
                    Buttons.google,
                    text: "Fortsett med Google",
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      try {
                        await _authData.authenticateGoogle();
                      } catch (error) {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title: const Text('Feil'),
                            content: const Text(
                                'Det har oppstått en feil med innloggingen. '
                                'Sjekk internett tilkoblingen din eller prøv igjen senere.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: const Text(
                                  'OK',
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
