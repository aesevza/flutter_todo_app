import '../repositories/todo_repository.dart';

class GetSelectedCategory {
  final TodoRepository repository;

  GetSelectedCategory(this.repository);

  Future<String?> call() async {
    return await repository.getSelectedCategory();
  }
} 