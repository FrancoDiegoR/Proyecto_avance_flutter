import 'package:flutter/material.dart';

import 'iam/presentation/login_page.dart';
import 'shared/presentation/app_theme.dart';

void main() {
  runApp(const SmartGasApp());
}

/// App SmartGas en Flutter. Consume el mismo backend que la web y la app Android.
class SmartGasApp extends StatelessWidget {
  const SmartGasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGas',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const LoginPage(),
    );
  }
}
