import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final loading = false;

  @override
  Widget build(BuildContext context) {
    final _mediaQueryData = MediaQuery.of(context);
    final _authData = Provider.of<Auth>(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          _mediaQueryData.size.width * 0.10,
          120,
          _mediaQueryData.size.width * 0.10,
          30,
        ),
        children: <Widget>[
          Center(
            child:
                Image.asset('assets/images/logo_transparent.png', height: 250),
          ),
          const SizedBox(
            height: 70,
          ),
          SizedBox(
            height: 55,
            child: FilledButton(
              onPressed: () async {
                try {
                  await _authData.authenticate();
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
                            Navigator.of(context, rootNavigator: true).pop();
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/untappd_logo.png',
                    height: 30,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const Text(
                    'Logg inn med Untappd',
                    textAlign: TextAlign.center,
                  ),
                  Column()
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          const Center(
            child: Text(
              'eller',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFaaaaaa),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: TextButton(
              child: const Text(
                'Logg inn senere...',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _authData.skipLogin(true),
            ),
          ),
        ],
      ),
    );
  }
}
