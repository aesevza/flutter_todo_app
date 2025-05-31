import 'dart:developer';
import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';
import '../../domain/entities/category.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodosLoaded extends TodoState {
  final List<Todo> todos;
  final List<Category> categories;
  final String? selectedCategory;

  const TodosLoaded({
    required this.todos,
    required this.categories,
    this.selectedCategory,
  });

  List<Todo> get filteredTodos {
    // Выводим в консоль для отладки
    log('Получение отфильтрованных задач. Выбранная категория: $selectedCategory');
    log('Всего задач: ${todos.length}');
    
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      // Если категория не выбрана или пустая строка, возвращаем все задачи
      log('Возвращаем все задачи без фильтрации');
      return todos;
    }
    
    // Иначе фильтруем по выбранной категории
    final filteredList = todos.where((todo) => todo.category == selectedCategory).toList();
    log('Отфильтровано ${filteredList.length} задач по категории "$selectedCategory"');
    return filteredList;
  }

  TodosLoaded copyWith({
    List<Todo>? todos,
    List<Category>? categories,
    String? selectedCategory,
  }) {
    return TodosLoaded(
      todos: todos ?? this.todos,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [todos, categories, selectedCategory];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
} 