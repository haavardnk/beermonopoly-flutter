import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../../validators/auth_validator.dart';

class AuthForgottenPasswordScreen extends StatefulWidget {
  const AuthForgottenPasswordScreen({Key? key}) : super(key: key);
  static const routeName = '/auth/login/forgotpassword';

  @override
  State<AuthForgottenPasswordScreen> createState() =>
      _AuthForgottenPasswordScreenState();
}

class _AuthForgottenPasswordScreenState
    extends State<AuthForgottenPasswordScreen> {
  final GlobalKey<FormState> _resetPasswordGlobalKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _mediaQueryData = MediaQuery.of(context);
    final _auth = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Glemt passord',
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          _mediaQueryData.size.width * 0.10,
          50,
          _mediaQueryData.size.width * 0.10,
          50,
        ),
        child: Form(
          key: _resetPasswordGlobalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Name Input -------------------------------------
              TextFormField(
                controller: emailController,
                enableSuggestions: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: AuthValidator.isEmailValid,
                decoration: const InputDecoration(
                  hintText: "E-Post",
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sign In Button ----------------------------------
                  FilledButton(
                    child: Text(
                      "Send",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () async {
                      if (_resetPasswordGlobalKey.currentState!.validate()) {
                        try {
                          var _status = await _auth.resetPassword(
                            emailController.text.trim(),
                            context,
                          );
                          if (_status) {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                title: const Text('Tilbakestill passord'),
                                content: Text(
                                  'En e-post med instrukser for å tilbakestille passordet ditt er sendt '
                                  'til den oppgitt e-postadressen.',
                                ),
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
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        } catch (error) {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              title: const Text('En feil har oppstått'),
                              content: Text(
                                error.toString(),
                              ),
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
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
