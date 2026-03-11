import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '{{feature_name}}_event.dart';
part '{{feature_name}}_state.dart';

class {{feature_name.pascalCase()}}Bloc extends Bloc<{{feature_name.pascalCase()}}Event, {{feature_name.pascalCase()}}State> {
  {{feature_name.pascalCase()}}Bloc() : super(const {{feature_name.pascalCase()}}State()) {
    {{#use_status_enum}}
    on<{{feature_name.pascalCase()}}InitialEvent>(_onInitialEvent);
    {{/use_status_enum}}
    {{^use_status_enum}}
    on<{{feature_name.pascalCase()}}Event>((event, emit) {
      // TODO: implement event handler
    });
    {{/use_status_enum}}
  }

  {{#use_status_enum}}
  void _onInitialEvent(
    {{feature_name.pascalCase()}}InitialEvent event,
    Emitter<{{feature_name.pascalCase()}}State> emit,
  ) {
    emit(state.copyWith(status: {{feature_name.pascalCase()}}Status.loading));
    // TODO: implement logic
    emit(state.copyWith(status: {{feature_name.pascalCase()}}Status.success));
  }
  {{/use_status_enum}}
}
