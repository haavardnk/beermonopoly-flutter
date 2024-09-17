import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../providers/auth.dart';
import '../../validators/auth_validator.dart';

class AuthEmailVerificationScreen extends StatefulWidget {
  const AuthEmailVerificationScreen({Key? key}) : super(key: key);
  static const routeName = '/register';

  @override
  State<AuthEmailVerificationScreen> createState() =>
      _AuthEmailVerificationScreenState();
}

class _AuthEmailVerificationScreenState
    extends State<AuthEmailVerificationScreen> {
  final GlobalKey<FormState> _verifyEmailGlobalKey = GlobalKey<FormState>();
  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verifiser epost',
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme:
            Theme.of(context).appBarTheme.iconTheme, //change your color here
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _verifyEmailGlobalKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 55),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Input -------------------------------------
                    TextFormField(
                      controller: codeController,
                      enableSuggestions: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: AuthValidator.isNameValid,
                      decoration: const InputDecoration(
                        hintText: "Kode",
                      ),
                    ),

                    const SizedBox(height: 120),
                    // Sign Up for Button ----------------------------------
                    FilledButton(
                      child: Text("Registrer"),
                      onPressed: () async {
                        if (_verifyEmailGlobalKey.currentState!.validate()) {
                          final apiResponse = await http.post(
                            Uri.parse(
                                'https://api.beermonopoly.com/_allauth/app/v1/auth/email/verify'),
                            headers: {
                              'Content-type': 'application/json',
                            },
                            body: jsonEncode(
                              {"key": codeController.text.trim()},
                            ),
                          );

                          final apiData = json.decode(apiResponse.body);
                          print(apiData);
                        }
                        ;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
