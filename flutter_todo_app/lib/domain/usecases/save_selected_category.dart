import '../repositories/todo_repository.dart';

class SaveSelectedCategory {
  final TodoRepository repository;

  SaveSelectedCategory(this.repository);

  Future<void> call(String? category) async {
    return await repository.saveSelectedCategory(category);
  }
} 