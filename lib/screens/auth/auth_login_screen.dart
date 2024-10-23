import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../providers/auth.dart';
import '../../validators/auth_validator.dart';
import 'auth_forgotten_password_screen.dart';

class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({Key? key}) : super(key: key);
  static const routeName = '/auth/login';

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen> {
  final GlobalKey<FormState> _signInGlobalKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passwordSee = true;

  @override
  Widget build(BuildContext context) {
    final _mediaQueryData = MediaQuery.of(context);
    final _auth = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logg inn',
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
          key: _signInGlobalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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

                  // Password Input -------------------------------------
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: passwordController,
                    enableSuggestions: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: passwordSee,
                    validator: AuthValidator.isPasswordValid,
                    decoration: InputDecoration(
                      hintText: "Passord",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          passwordSee = !passwordSee;
                          setState(() {});
                        },
                        child: Icon(
                          passwordSee
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sign In Button ----------------------------------
                  FilledButton(
                    child: Text(
                      "Logg inn",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () async {
                      if (_signInGlobalKey.currentState!.validate()) {
                        try {
                          var _status = await _auth.login(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                            context,
                          );
                          if (_status) {
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
                        }
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextButton(
                      onPressed: () {
                        pushScreen(
                          context,
                          screen: AuthForgottenPasswordScreen(),
                        );
                      },
                      child: Text(
                        'Glemt passord?',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
