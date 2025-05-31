import 'dart:developer';
import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    super.isCompleted,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    // Выводим для отладки полученные данные
    log('TodoModel.fromJson: ${json.toString()}');
    
    // Адаптируем ответ от jsonplaceholder.typicode.com
    // jsonplaceholder не содержит поля description и category,
    // поэтому добавляем их на клиенте
    String description = '';
    String category = 'Общее';
    
    // Если есть поле body (в некоторых ответах jsonplaceholder), используем его как description
    if (json.containsKey('body')) {
      description = json['body'] ?? '';
    }
    
    // Распределяем задачи по категориям на основе userId (если есть)
    if (json.containsKey('userId')) {
      int userId = json['userId'] ?? 0;
      switch (userId % 4) {
        case 0:
          category = 'Общее';
          break;
        case 1:
          category = 'Работа';
          break;
        case 2:
          category = 'Личное';
          break;
        case 3:
          category = 'Покупки';
          break;
      }
    }

    final model = TodoModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch,
      title: json['title'] ?? 'Без названия',
      description: json.containsKey('description') ? json['description'] : description,
      category: json.containsKey('category') ? json['category'] : category,
      isCompleted: json['completed'] ?? false,
    );
    
    log('Преобразовано в TodoModel: ${model.title}, категория: ${model.category}');
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'completed': isCompleted,
    };
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      category: todo.category,
      isCompleted: todo.isCompleted,
    );
  }
} 