import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/create_todo.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_selected_category.dart';
import '../../domain/usecases/save_selected_category.dart';
import '../../domain/entities/todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final CreateTodo createTodo;
  final GetCategories getCategories;
  final GetSelectedCategory getSelectedCategory;
  final SaveSelectedCategory saveSelectedCategory;
  final Dio dio = Dio(); 

  TodoBloc({
    required this.getTodos,
    required this.createTodo,
    required this.getCategories,
    required this.getSelectedCategory,
    required this.saveSelectedCategory,
  }) : super(const TodoInitial()) {
    on<TodosLoadEvent>(_onTodosLoad);
    on<TodosFilteredByCategory>(_onTodosFilteredByCategory);
    on<TodoCreatedEvent>(_onTodoCreated);
    
    _checkServerAvailability();
  }
  
  Future<void> _checkServerAvailability() async {
    try {
      log('Проверка доступности сервера...');
      final response = await dio.get('https://jsonplaceholder.typicode.com/todos/1');
      if (response.statusCode == 200) {
        log('Сервер доступен! Получен ответ: ${response.data}');
      } else {
        log('Сервер недоступен! Статус: ${response.statusCode}');
      }
    } catch (e) {
      log('Ошибка при проверке доступности сервера: $e');
    }
  }

  Future<void> _onTodosLoad(TodosLoadEvent event, Emitter<TodoState> emit) async {
    emit(const TodoLoading());
    try {
      log('Загрузка списка задач...');
      final todos = await getTodos();
      log('Получено ${todos.length} задач');
      
      final categories = await getCategories();
      log('Получено ${categories.length} категорий');
      
      final selectedCategory = await getSelectedCategory();
      log('Выбранная категория: $selectedCategory');
      
      emit(TodosLoaded(
        todos: todos,
        categories: categories,
        selectedCategory: selectedCategory,
      ));
    } catch (e) {
      log('Ошибка при загрузке данных: $e');
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onTodosFilteredByCategory(TodosFilteredByCategory event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final currentState = state as TodosLoaded;
      
      log('Фильтрация по категории: ${event.category}');
      
      await saveSelectedCategory(event.category);
      
      final newState = TodosLoaded(
        todos: currentState.todos,
        categories: currentState.categories,
        selectedCategory: event.category,
      );
      
      emit(newState);
    }
  }

  Future<void> _onTodoCreated(TodoCreatedEvent event, Emitter<TodoState> emit) async {
    try {
      log('Создание новой задачи: ${event.todo.title}');
      await createTodo(event.todo);
      log('Задача успешно создана');
      
      if (state is TodosLoaded) {
        final currentState = state as TodosLoaded;
        final updatedTodos = List<Todo>.from(currentState.todos)..add(event.todo);
        log('Обновлен список задач, текущее количество: ${updatedTodos.length}');
        emit(currentState.copyWith(todos: updatedTodos));
      }
    } catch (e) {
      log('Ошибка при создании задачи: $e');
      emit(TodoError(e.toString()));
    }
  }
} 