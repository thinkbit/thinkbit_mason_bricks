part of '{{feature_name}}_bloc.dart';

sealed class {{feature_name.pascalCase()}}Event extends Equatable {
  const {{feature_name.pascalCase()}}Event();

  @override
  List<Object?> get props => [];
}

{{#use_status_enum}}
class {{feature_name.pascalCase()}}InitialEvent extends {{feature_name.pascalCase()}}Event {
  const {{feature_name.pascalCase()}}InitialEvent();
}
{{/use_status_enum}}
