import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data_models/user.dart';
import 'screens/auth/authentication_screen.dart';
import 'screens/home.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<CustomUser?>(context);
    return (userId != null) ? HomePage(userID: userId) : const Authenticate();
  }
}
