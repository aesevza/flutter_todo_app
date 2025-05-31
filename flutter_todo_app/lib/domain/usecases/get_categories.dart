import '../entities/category.dart';
import '../repositories/todo_repository.dart';

class GetCategories {
  final TodoRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
} 