import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skinspectra/auth/firebase_auth_helper.dart';
import 'package:skinspectra/screens/ProfileScreen.dart';
import 'package:skinspectra/screens/registerPage.dart';
import 'package:skinspectra/auth/validator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  String _errorMessage = '';

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),

                        //Login Logo
                        Image.asset(
                          'assets/login_logo.png',
                          height: 200,
                        ),
                        //welcome text
                        const SizedBox(height: 24.0),
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            color: Color(0xFF328B8C),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        //login into your account
                        const Text(
                          'Login into your account',
                          style: TextStyle(
                            color: Color(0xFF694F5E),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        TextFormField(
                          controller: _emailTextController,
                          focusNode: _focusEmail,
                          validator: (value) => Validator.validateEmail(
                            email: value,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Email",
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _passwordTextController,
                          focusNode: _focusPassword,
                          obscureText: true,
                          validator: (value) => Validator.validatePassword(
                            password: value,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Password",
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        //forgot password text button on right bottom of password textfield
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFFEA4335),
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 24.0),
                        if (_isProcessing)
                          const CircularProgressIndicator(
                            color: Color(0xFF328B8C),
                          )
                        else
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (_errorMessage.isNotEmpty)
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),

                              //Sign In Button
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 50.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF328B8C),
                                  ),
                                  onPressed: () async {
                                    _focusEmail.unfocus();
                                    _focusPassword.unfocus();

                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        setState(() {
                                          _isProcessing = true;
                                          _errorMessage = '';
                                        });

                                        await FirebaseAuthHelper
                                            .signInUsingEmailPassword(
                                          email: _emailTextController.text,
                                          password:
                                              _passwordTextController.text,
                                        );

                                        // setState(() {
                                        //   _isProcessing = false;
                                        // });
                                      } on FirebaseAuthException catch (e) {
                                        // Display an alert dialog containing the humanize error message
                                        _showErrorDialog(e);
                                        print('Test ${e.code}');
                                        setState(() {
                                          _isProcessing = false;
                                        });
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'LogIn',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24.0),

                              //don't have an account? sign up
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Don\'t have an account?',
                                    style: TextStyle(
                                      color: Color(0xFF694F5E),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Color(0xFFD9D9D9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  //code of _showErrorDialog
  void _showErrorDialog(FirebaseAuthException e) {
    String errorMessage = '';
    switch (e.code) {
      // case error for registration
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      case 'user-disabled':
        errorMessage = 'The user account has been disabled.';
        break;
      case 'USER-NOT-FOUND':
        errorMessage = 'The user account has not been found.';
        break;
      case 'wrong-password':
        errorMessage = 'Invalid password.';
        break;
      case 'EMAIL-ALREADY-IN-USE':
        errorMessage = 'An account already exists with that email address.';
        break;
      default:
        errorMessage = 'An undefined Error happened.';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
