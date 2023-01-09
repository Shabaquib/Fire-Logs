import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data_models/authservice.dart';
import '../../data_models/global_data.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final AuthService _auth = AuthService();
  int authChoice = 1;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Widget authWithCredentials(int authvalue) {
    OutlineInputBorder errorBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0),
      borderRadius: BorderRadius.all(
        Radius.circular(15.0),
      ),
    );

    OutlineInputBorder normalBorder = OutlineInputBorder(
      borderSide: BorderSide(
          color: (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black),
          width: 1.0),
      borderRadius: const BorderRadius.all(
        Radius.circular(15.0),
      ),
    );

    return Center(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: TextFormField(
                validator: (value) {
                  String? result = "Enter a valid email address";
                  if (value != null) {
                    for (int i = 0; i < emailProviders.length; i++) {
                      if (value.endsWith(emailProviders[i])) {
                        result = null;
                        break;
                      } else {
                        result = "Enter a valid email address";
                      }
                    }
                  } else {
                    result = "Enter an email address";
                  }
                  return result;
                },
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: "Email",
                  helperText: " ",
                  enabledBorder: normalBorder,
                  focusedBorder: normalBorder,
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorBorder,
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: TextFormField(
                controller: passwordController,
                validator: (value) {
                  if (value != null) {
                    return (value.length < 6)
                        ? "password has atleast 6 characters"
                        : null;
                  } else {
                    return "We need a password too!";
                  }
                },
                obscureText: true,
                obscuringCharacter: '◦',
                decoration: InputDecoration(
                  helperText: " ",
                  prefixIcon: const Icon(Icons.key_rounded),
                  hintText: "password",
                  enabledBorder: normalBorder,
                  focusedBorder: normalBorder,
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorBorder,
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState != null) {
                  if (formKey.currentState!.validate()) {
                    if (authvalue == 2) {
                      await _auth
                          .signUpEmailandPassword(
                              emailController.text, passwordController.text)
                          .then((value) {
                        if (value != null) {
                          showToast(context, "Signup successful");
                        } else {
                          showToast(context, "Couldn't create an account");
                        }
                      });
                    } else {
                      _auth
                          .logInEmailandPassword(
                              emailController.text, passwordController.text)
                          .then((value) {
                        if (value != null) {
                          Fluttertoast.showToast(
                            msg: "Logged In",
                            gravity: ToastGravity.TOP,
                            textColor: (Theme.of(context).brightness ==
                                    Brightness.dark)
                                ? Colors.black
                                : Colors.white,
                            backgroundColor: (Theme.of(context).brightness ==
                                    Brightness.dark)
                                ? Colors.white
                                : Colors.black,
                          );
                        }
                      });
                    }
                  } else {
                    print("Literally Nothing!");
                  }
                }
              },
              child: Text((authvalue == 1)
                  ? "Proceed to sign in"
                  : "Proceed to sign up"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.2,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Authenticate",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Login or register with us!",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ), //Auth heading
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.2,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            authChoice = 1;
                          });
                        },
                        child: MethodToggles(
                            choice: (authChoice == 1),
                            label: "Sign in",
                            svgPath: "Assets/SvgAssets/icon-verify.svg"),
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              authChoice = 2;
                            });
                          },
                          child: MethodToggles(
                              choice: (authChoice == 2),
                              label: "Sign up",
                              svgPath: "Assets/SvgAssets/icon-add.svg")),
                    ],
                  ),
                ),
                SizedBox(
                  width: screenWidth,
                  height: screenHeight * 0.6,
                  child: authWithCredentials(authChoice),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<String>(
              valueListenable: errorCode,
              builder: (a, b, c) {
                if (b != "Well") {
                  showToast(context, b);
                }
                return const SizedBox();
              }),
        ],
      ),
    );
  }
}

class MethodToggles extends StatelessWidget {
  const MethodToggles(
      {Key? key,
      required this.choice,
      required this.label,
      required this.svgPath})
      : super(key: key);
  final bool choice;
  final String label;
  final String svgPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: (choice)
            ? Colors.amber.shade400
            : ((Theme.of(context).brightness == Brightness.dark)
                ? const Color.fromARGB(255, 39, 39, 39)
                : Colors.teal.shade50),
        borderRadius: const BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: (Theme.of(context).brightness == Brightness.dark)
                  ? const Color.fromARGB(255, 30, 30, 30)
                  : Colors.white,
              // color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              svgPath,
              width: 24.0,
              height: 24.0,
              color: (Theme.of(context).brightness == Brightness.dark)
                  ? Colors.white
                  : const Color.fromARGB(255, 30, 30, 30),
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            label,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.light
                  ? (Colors.black)
                  : ((choice) ? Colors.black : Colors.white)),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
