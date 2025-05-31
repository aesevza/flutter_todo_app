import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class TodosLoadEvent extends TodoEvent {
  const TodosLoadEvent();
}

class TodosFilteredByCategory extends TodoEvent {
  final String? category;

  const TodosFilteredByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class TodoCreatedEvent extends TodoEvent {
  final Todo todo;

  const TodoCreatedEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class TodoUpdatedEvent extends TodoEvent {
  final Todo todo;

  const TodoUpdatedEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class TodoDeletedEvent extends TodoEvent {
  final int id;

  const TodoDeletedEvent(this.id);

  @override
  List<Object?> get props => [id];
}
