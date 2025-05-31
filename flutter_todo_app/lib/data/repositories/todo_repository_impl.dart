import '../../domain/entities/todo.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_remote_data_source.dart';
import '../datasources/todo_local_data_source.dart';
import '../models/todo_model.dart';
import '../models/category_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Todo>> getTodos() async {
    try {
      // Сначала пытаемся получить задачи с сервера
      final todoModels = await remoteDataSource.getTodos();
      
      // Сохраняем полученные задачи в локальное хранилище
      await localDataSource.saveTodos(todoModels);
      
      return todoModels;
    } catch (e) {
      // При ошибке загружаем из локального хранилища
      final localTodos = await localDataSource.getTodos();
      
      // Если локальных данных нет, возвращаем пустой список
      if (localTodos.isEmpty) {
        return [];
      }
      
      return localTodos;
    }
  }

  @override
  Future<Todo> getTodoById(int id) async {
    try {
      final todoModel = await remoteDataSource.getTodoById(id);
      return todoModel;
    } catch (e) {
      final todos = await localDataSource.getTodos();
      final todo = todos.firstWhere(
        (todo) => todo.id == id,
        orElse: () => throw Exception('Todo not found'),
      );
      return todo;
    }
  }

  @override
  Future<Todo> createTodo(Todo todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final createdTodo = await remoteDataSource.createTodo(todoModel);
      
      // Обновляем локальное хранилище
      final todos = await localDataSource.getTodos();
      todos.add(createdTodo);
      await localDataSource.saveTodos(todos);
      
      return createdTodo;
    } catch (e) {
      // Если нет сети, сохраняем только локально
      final todoModel = TodoModel.fromEntity(todo);
      final todos = await localDataSource.getTodos();
      todos.add(todoModel);
      await localDataSource.saveTodos(todos);
      return todoModel;
    }
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final updatedTodo = await remoteDataSource.updateTodo(todoModel);
      
      // Обновляем локальное хранилище
      final todos = await localDataSource.getTodos();
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index >= 0) {
        todos[index] = updatedTodo;
        await localDataSource.saveTodos(todos);
      }
      
      return updatedTodo;
    } catch (e) {
      // Если нет сети, обновляем только локально
      final todoModel = TodoModel.fromEntity(todo);
      final todos = await localDataSource.getTodos();
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index >= 0) {
        todos[index] = todoModel;
        await localDataSource.saveTodos(todos);
      }
      return todoModel;
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      await remoteDataSource.deleteTodo(id);
      
      // Обновляем локальное хранилище
      final todos = await localDataSource.getTodos();
      todos.removeWhere((todo) => todo.id == id);
      await localDataSource.saveTodos(todos);
    } catch (e) {
      // Если нет сети, удаляем только локально
      final todos = await localDataSource.getTodos();
      todos.removeWhere((todo) => todo.id == id);
      await localDataSource.saveTodos(todos);
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      // Сначала пытаемся получить категории с сервера
      final categoryModels = await remoteDataSource.getCategories();
      // Сохраняем в локальное хранилище
      await localDataSource.saveCategories(categoryModels);
      return categoryModels;
    } catch (e) {
      // При ошибке возвращаем данные из локального хранилища
      final localCategories = await localDataSource.getCategories();
      if (localCategories.isEmpty) {
        // Если локальных данных нет, возвращаем дефолтные категории
        final defaultCategories = [
          const CategoryModel(id: '1', name: 'Работа'),
          const CategoryModel(id: '2', name: 'Личное'),
          const CategoryModel(id: '3', name: 'Покупки'),
          const CategoryModel(id: '4', name: 'Общее'),
        ];
        await localDataSource.saveCategories(defaultCategories);
        return defaultCategories;
      }
      return localCategories;
    }
  }

  @override
  Future<String?> getSelectedCategory() async {
    return localDataSource.getSelectedCategory();
  }

  @override
  Future<void> saveSelectedCategory(String? category) async {
    await localDataSource.saveSelectedCategory(category);
  }
} 