import '../entities/todo.dart';
import '../entities/category.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> getTodoById(int id);
  Future<Todo> createTodo(Todo todo);
  Future<Todo> updateTodo(Todo todo);
  Future<void> deleteTodo(int id);
  Future<List<Category>> getCategories();
  Future<String?> getSelectedCategory();
  Future<void> saveSelectedCategory(String? category);
} 