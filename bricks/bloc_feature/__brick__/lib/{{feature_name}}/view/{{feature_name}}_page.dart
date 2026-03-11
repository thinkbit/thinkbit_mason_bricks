import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/{{feature_name}}_bloc.dart';

class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  static Route<void> route() => MaterialPageRoute<void>(builder: (_) => const {{feature_name.pascalCase()}}Page());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => {{feature_name.pascalCase()}}Bloc(){{#use_status_enum}}..add(const {{feature_name.pascalCase()}}InitialEvent()){{/use_status_enum}},
      child: const {{feature_name.pascalCase()}}View(),
    );
  }
}

class {{feature_name.pascalCase()}}View extends StatelessWidget {
  const {{feature_name.pascalCase()}}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<{{feature_name.pascalCase()}}Bloc, {{feature_name.pascalCase()}}State>(
        builder: (context, state) {
          {{#use_status_enum}}
          switch (state.status) {
            case {{feature_name.pascalCase()}}Status.initial:
            case {{feature_name.pascalCase()}}Status.loading:
              return const Center(child: CircularProgressIndicator());
            case {{feature_name.pascalCase()}}Status.success:
              return const Center(child: Text('Success'));
            case {{feature_name.pascalCase()}}Status.failure:
              return const Center(child: Text('Failure'));
          }
          {{/use_status_enum}}
          {{^use_status_enum}}
          return const Center(child: Text('{{feature_name.pascalCase()}}View'));
          {{/use_status_enum}}
        },
      ),
    );
  }
}
