part of '{{feature_name}}_bloc.dart';

{{#use_status_enum}}
enum {{feature_name.pascalCase()}}Status { initial, loading, success, failure }
{{/use_status_enum}}

class {{feature_name.pascalCase()}}State extends Equatable {
  const {{feature_name.pascalCase()}}State({
    {{#use_status_enum}}
    this.status = {{feature_name.pascalCase()}}Status.initial,
    {{/use_status_enum}}
  });

  {{#use_status_enum}}
  final {{feature_name.pascalCase()}}Status status;
  {{/use_status_enum}}

  @override
  List<Object?> get props => [
    {{#use_status_enum}}
    status,
    {{/use_status_enum}}
  ];

  {{#use_copy_with}}
  {{feature_name.pascalCase()}}State copyWith({
    {{#use_status_enum}}
    {{feature_name.pascalCase()}}Status? status,
    {{/use_status_enum}}
  }) {
    return {{feature_name.pascalCase()}}State(
      {{#use_status_enum}}
      status: status ?? this.status,
      {{/use_status_enum}}
    );
  }
  {{/use_copy_with}}
}
