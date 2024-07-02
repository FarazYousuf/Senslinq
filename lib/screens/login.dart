import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senslinq/auth_provider.dart';
import 'package:senslinq/language_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (isValid) {
      _form.currentState!.save();
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token =
            await authProvider.loginUser(_enteredEmail, _enteredPassword);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: const Color.fromARGB(255, 230, 94, 94),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isCurrentLanguageArabic();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Form(
              key: _form,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 38,
                        bottom: 7,
                        left: 7,
                        right: 20,
                      ),
                      width: 220,
                      child: SvgPicture.asset(
                        'assets/logo.svg',
                        height: 150,
                        width: 150,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 230),
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(
                                      // labelText: 'Email',
                                      labelText: languageProvider
                                          .getTranslatedValue('emailLabel'),
                                      labelStyle: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0)),
                                      floatingLabelStyle: const TextStyle(
                                        color: Color.fromRGBO(54, 185, 140, 1),
                                      ),
                                    
                                      //  cursorColor: const Color.fromRGBO(54, 185, 140, 1),
                                      contentPadding: const EdgeInsets.all(11),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 192, 191, 191),
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(54, 185, 140, 1),
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    textAlign: isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    cursorColor:
                                        const Color.fromRGBO(54, 185, 140, 1),
                                    autocorrect: false,
                                    keyboardType: TextInputType.emailAddress,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          !value.contains('@')) {
                                        return 'Please enter a valid email address.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _enteredEmail = value!;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      // labelText: 'Password',
                                      labelText: languageProvider
                                          .getTranslatedValue('passwordLabel'),
                                      labelStyle: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0)),
                                      floatingLabelStyle: const TextStyle(
                                          color:
                                              Color.fromRGBO(54, 185, 140, 1)),
                                      contentPadding: const EdgeInsets.all(11),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 192, 191, 191),
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(54, 185, 140, 1),
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    textAlign: isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    cursorColor:
                                        const Color.fromRGBO(54, 185, 140, 1),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().length < 6) {
                                        return 'Password must be 6 characters';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _enteredPassword = value!;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 45),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 230),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(54, 185, 140, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: AutofillHints.location,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.85,
                                  ),
                                ),
                                child: 
                                // const Text('LOGIN',
                                Text(
                                  languageProvider
                                      .getTranslatedValue('loginButton'),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        // );
                      },
                      child: 
                      // const Text('forgot password?',
                      Text(
                        languageProvider
                            .getTranslatedValue('forgotPasswordLabel'),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}