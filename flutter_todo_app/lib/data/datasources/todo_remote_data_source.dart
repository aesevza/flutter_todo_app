import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/todo_model.dart';
import '../models/category_model.dart';
import 'mock_server.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> getTodoById(int id);
  Future<TodoModel> createTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
  Future<List<CategoryModel>> getCategories();
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final Dio dio;
  final MockServer mockServer = MockServer();

  TodoRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TodoModel>> getTodos() async {
    log('TodoRemoteDataSource: Получение списка задач с сервера');
    
    // Проверяем подключение к серверу
    final isConnected = await mockServer.checkConnection();
    log('Статус подключения к серверу: ${isConnected ? "Доступен" : "Недоступен"}');
    
    // Получаем данные с сервера (или мок-данные, если сервер недоступен)
    final todosData = await mockServer.getTodos();
    log('Получено ${todosData.length} задач с сервера');
    
    // Преобразуем в модели
    final todoModels = todosData.map((json) => TodoModel.fromJson(json)).toList();
    log('Преобразовано ${todoModels.length} задач в модели');
    
    return todoModels;
  }

  @override
  Future<TodoModel> getTodoById(int id) async {
    log('TodoRemoteDataSource: Получение задачи по ID $id с сервера');
    try {
      final response = await dio.get('https://jsonplaceholder.typicode.com/todos/$id');
      log('Получен ответ: ${response.data}');
      return TodoModel.fromJson(response.data);
    } catch (e) {
      log('Ошибка при загрузке задачи: $e');
      // Имитируем получение задачи с сервера
      return TodoModel(
        id: id,
        title: 'Тестовая задача $id',
        description: 'Это тестовая задача с сервера',
        category: 'Общее',
        isCompleted: false,
      );
    }
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    log('TodoRemoteDataSource: Создание новой задачи "${todo.title}" на сервере');
    
    // Отправляем задачу на сервер
    final createdTodoData = await mockServer.createTodo(todo.toJson());
    log('Получен ответ от сервера: $createdTodoData');
    
    // Создаем модель из ответа
    return TodoModel.fromJson(createdTodoData);
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    log('TodoRemoteDataSource: Обновление задачи "${todo.title}" на сервере');
    try {
      final response = await dio.put(
        'https://jsonplaceholder.typicode.com/todos/${todo.id}',
        data: todo.toJson(),
      );
      log('Получен ответ от сервера: ${response.data}');
      return TodoModel.fromJson(response.data);
    } catch (e) {
      log('Ошибка при обновлении задачи: $e');
      // Имитируем ответ сервера
      return todo;
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    log('TodoRemoteDataSource: Удаление задачи с ID $id на сервере');
    try {
      await dio.delete('https://jsonplaceholder.typicode.com/todos/$id');
      log('Задача успешно удалена на сервере');
    } catch (e) {
      log('Ошибка при удалении задачи: $e');
      // В случае ошибки имитируем успешное удаление
      log('Имитация успешного удаления на сервере');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    log('TodoRemoteDataSource: Получение списка категорий с сервера');
    
    // Получаем категории с мок-сервера
    final categoriesData = await mockServer.getCategories();
    log('Получено ${categoriesData.length} категорий с сервера');
    
    // Преобразуем в модели
    return categoriesData.map((json) => CategoryModel.fromJson(json)).toList();
  }
} 