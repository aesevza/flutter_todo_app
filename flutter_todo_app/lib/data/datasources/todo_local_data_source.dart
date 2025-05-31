import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';
import '../models/category_model.dart';

abstract class TodoLocalDataSource {
  Future<void> saveTodos(List<TodoModel> todos);
  Future<List<TodoModel>> getTodos();
  Future<void> saveCategories(List<CategoryModel> categories);
  Future<List<CategoryModel>> getCategories();
  Future<void> saveSelectedCategory(String? category);
  Future<String?> getSelectedCategory();
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  static const String _todosKey = 'todos';
  static const String _categoriesKey = 'categories';
  static const String _selectedCategoryKey = 'selected_category';

  final SharedPreferences _prefs;

  TodoLocalDataSourceImpl(this._prefs);

  @override
  Future<List<TodoModel>> getTodos() async {
    final todosJson = _prefs.getStringList(_todosKey);
    if (todosJson == null) {
      return [];
    }

    return todosJson
        .map((todoJson) => TodoModel.fromJson(json.decode(todoJson)))
        .toList();
  }

  @override
  Future<void> saveTodos(List<TodoModel> todos) async {
    final todosJson = todos
        .map((todo) => json.encode(todo.toJson()))
        .toList();

    await _prefs.setStringList(_todosKey, todosJson);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final categoriesJson = _prefs.getStringList(_categoriesKey);
    if (categoriesJson == null) {
      return [];
    }

    return categoriesJson
        .map((categoryJson) => CategoryModel.fromJson(json.decode(categoryJson)))
        .toList();
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    final categoriesJson = categories
        .map((category) => json.encode(category.toJson()))
        .toList();

    await _prefs.setStringList(_categoriesKey, categoriesJson);
  }

  @override
  Future<String?> getSelectedCategory() async {
    return _prefs.getString(_selectedCategoryKey);
  }

  @override
  Future<void> saveSelectedCategory(String? category) async {
    if (category == null) {
      await _prefs.remove(_selectedCategoryKey);
    } else {
      await _prefs.setString(_selectedCategoryKey, category);
    }
  }
} 