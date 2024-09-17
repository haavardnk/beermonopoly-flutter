import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../../validators/auth_validator.dart';

class AuthRegistrationScreen extends StatefulWidget {
  const AuthRegistrationScreen({Key? key}) : super(key: key);
  static const routeName = '/register';

  @override
  State<AuthRegistrationScreen> createState() => _AuthRegistrationScreenState();
}

class _AuthRegistrationScreenState extends State<AuthRegistrationScreen> {
  final GlobalKey<FormState> _signUpGlobalKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRetryController = TextEditingController();
  bool passwordSee = true;

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ny Bruker',
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
            key: _signUpGlobalKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 55),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Input -------------------------------------
                    TextFormField(
                      controller: nameController,
                      enableSuggestions: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: AuthValidator.isNameValid,
                      decoration: const InputDecoration(
                        hintText: "Brukernavn",
                      ),
                    ),

                    // Email Input -------------------------------------
                    const SizedBox(height: 40),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
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

                    // Retry Password Input -------------------------------------
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: passwordRetryController,
                      enableSuggestions: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: passwordSee,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        if (passwordController.text !=
                            passwordRetryController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Passord",
                      ),
                    ),
                    const SizedBox(height: 120),
                    // Sign Up for Button ----------------------------------
                    FilledButton(
                      child: Text("Registrer"),
                      onPressed: () async {
                        if (_signUpGlobalKey.currentState!.validate()) {
                          var _status = await _auth.registerWithEmail(
                            nameController.text.trim(),
                            passwordController.text.trim(),
                            emailController.text.trim(),
                            context,
                          );
                          if (_status) {
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
      ),
    );
  }
}
