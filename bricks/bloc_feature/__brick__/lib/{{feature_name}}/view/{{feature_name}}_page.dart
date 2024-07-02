import 'package:flutter/material.dart';

class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  static Route<void> route() => MaterialPageRoute<void>(builder: (_) => const {{feature_name.pascalCase()}}Page());

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
