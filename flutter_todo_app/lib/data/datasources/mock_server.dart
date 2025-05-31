import 'dart:developer';
import 'dart:async';
import 'package:dio/dio.dart';



class MockServer {
  static final MockServer _instance = MockServer._internal();
  final Dio _dio = Dio();
  
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  factory MockServer() => _instance;
  
  MockServer._internal();
  
  Future<bool> checkConnection() async {
    try {
      log('Проверка подключения к серверу jsonplaceholder...');
      final response = await _dio.get('$baseUrl/todos/1');
      return response.statusCode == 200;
    } catch (e) {
      log('Ошибка подключения к серверу: $e');
      return false;
    }
  }
  
  Future<List<Map<String, dynamic>>> getTodos() async {
    try {
      log('Прямая загрузка данных с $baseUrl/todos');
      
      final dio = Dio();
      dio.options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };
      
      final response = await dio.get('$baseUrl/todos');
      
      if (response.statusCode == 200 && response.data is List) {
        log('Успешно загружены данные с jsonplaceholder.typicode.com: ${response.data.length} задач');
        
        final List<dynamic> rawData = response.data;
        
        final limitedData = rawData.take(20).toList();
        log('Ограничено до ${limitedData.length} задач для отображения');
        
        final List<Map<String, dynamic>> todos = limitedData.map((item) {
          final Map<String, dynamic> todo = Map<String, dynamic>.from(item);
          
          final userId = todo['userId'] ?? 1;
          todo['description'] = 'Задача с jsonplaceholder.typicode.com #${todo['id']}';
          
          switch (userId % 4) {
            case 0: todo['category'] = 'Общее'; break;
            case 1: todo['category'] = 'Работа'; break;
            case 2: todo['category'] = 'Личное'; break;
            case 3: todo['category'] = 'Покупки'; break;
          }
          
          log('Преобразована задача: ${todo['title']}');
          return todo;
        }).toList();
        
        log('Всего преобразовано ${todos.length} задач с сервера');
        return todos;
      } else {
        log('Ошибка ответа API: ${response.statusCode}');
        throw Exception('API вернул некорректный ответ: ${response.statusCode}');
      }
    } catch (e) {
      log('Ошибка при загрузке данных с jsonplaceholder.typicode.com: $e');
      
      log('Возвращаем мок-данные (аварийный режим)');
      return _getMockTodos();
    }
  }
  
  Future<List<Map<String, dynamic>>> getCategories() async {
    return [
      {'id': '1', 'name': 'Работа'},
      {'id': '2', 'name': 'Личное'},
      {'id': '3', 'name': 'Покупки'},
      {'id': '4', 'name': 'Общее'},
    ];
  }
  
  Future<Map<String, dynamic>> createTodo(Map<String, dynamic> todoData) async {
    try {
      log('Отправка новой задачи на $baseUrl/todos');
      log('Данные для отправки: $todoData');
      
      final dio = Dio();
      dio.options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };
      
      final response = await dio.post(
        '$baseUrl/todos',
        data: todoData,
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        log('Задача успешно создана на сервере');
        log('Ответ сервера: ${response.data}');
        
        final Map<String, dynamic> createdTodo = Map<String, dynamic>.from(response.data);
        
        if (!createdTodo.containsKey('description') && todoData.containsKey('description')) {
          createdTodo['description'] = todoData['description'];
        }
        
        if (!createdTodo.containsKey('category') && todoData.containsKey('category')) {
          createdTodo['category'] = todoData['category'];
        }
        
        log('Итоговые данные новой задачи: $createdTodo');
        return createdTodo;
      } else {
        log('Ошибка при создании задачи: ${response.statusCode}');
        throw Exception('Ошибка создания задачи: ${response.statusCode}');
      }
    } catch (e) {
      log('Ошибка при отправке данных на сервер: $e');
      
      log('Имитация создания задачи на сервере (аварийный режим)');
      final createdTodo = Map<String, dynamic>.from(todoData);
      createdTodo['id'] = DateTime.now().millisecondsSinceEpoch;
      return createdTodo;
    }
  }
  
  List<Map<String, dynamic>> _getMockTodos() {
    return [
      // {
      //   'id': 1,
      //   'title': 'Мок-задача 1 с сервера',
      //   'description': 'Это первая мок-задача с сервера',
      //   'category': 'Работа',
      //   'completed': false,
      // },
      // {
      //   'id': 2,
      //   'title': 'Мок-задача 2 с сервера',
      //   'description': 'Это вторая мок-задача с сервера',
      //   'category': 'Личное',
      //   'completed': true,
      // },
      // {
      //   'id': 3,
      //   'title': 'Мок-задача 3 с сервера',
      //   'description': 'Это третья мок-задача с сервера',
      //   'category': 'Покупки',
      //   'completed': false,
      // },
      // {
      //   'id': 4,
      //   'title': 'Мок-задача 4 с сервера',
      //   'description': 'Это четвертая мок-задача с сервера',
      //   'category': 'Общее',
      //   'completed': false,
      // },
      // {
      //   'id': 5,
      //   'title': 'Мок-задача 5 с сервера',
      //   'description': 'Это пятая мок-задача с сервера',
      //   'category': 'Работа',
      //   'completed': true,
      // },
    ];
  }
} 