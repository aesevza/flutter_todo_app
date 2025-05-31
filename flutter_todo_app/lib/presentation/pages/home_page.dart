import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import 'create_todo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Приложение'),
        actions: [
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state is TodoLoading) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Сервер'),
                    ],
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Загрузить с сервера',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Загрузка данных с сервера...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  context.read<TodoBloc>().add(const TodosLoadEvent());
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: Colors.blueGrey.shade50,
            child: Row(
              children: [
                const Spacer(),
                BlocBuilder<TodoBloc, TodoState>(
                  builder: (context, state) {
                    if (state is TodosLoaded) {
                      return Text(
                        'Всего задач: ${state.todos.length}',
                        style: const TextStyle(fontSize: 12),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoInitial) {
                  context.read<TodoBloc>().add(const TodosLoadEvent());
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Загрузка задач с сервера...'),
                        
                      ],
                    ),
                  );
                } else if (state is TodoLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Загрузка задач с сервера...'),
                        SizedBox(height: 8),
                        
                      ],
                    ),
                  );
                } else if (state is TodosLoaded) {
                  return _buildTodoList(context, state);
                } else if (state is TodoError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text('Ошибка: ${state.message}'),
                        const SizedBox(height: 8),
                        const Text(
                          'Не удалось загрузить данные с сервера jsonplaceholder.typicode.com',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<TodoBloc>().add(
                              const TodosLoadEvent(),
                            );
                          },
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('Неизвестное состояние'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 15),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTodoPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Создать задачу'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, TodosLoaded state) {
    if (state.todos.isEmpty) {
      return const Center(child: Text('Нет задач. Создайте первую задачу!'));
    }

    return Column(
      children: [
        _buildCategoryFilter(context, state.categories, state.selectedCategory),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Задачи${state.selectedCategory == null ? "" : " в категории \"${state.selectedCategory}\""}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text('Всего: ${state.filteredTodos.length}'),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Данные загружены с jsonplaceholder.typicode.com',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              state.filteredTodos.isEmpty
                  ? const Center(child: Text('Нет задач в этой категории'))
                  : ListView.builder(
                    itemCount: state.filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = state.filteredTodos[index];
                      return _buildTodoItem(todo);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(
    BuildContext context,
    List<Category> categories,
    String? selectedCategory,
  ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, 
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              context,
              'Все',
              selectedCategory == null,
              () => context.read<TodoBloc>().add(TodosFilteredByCategory(null)),
            );
          }

          final category = categories[index - 1];
          return _buildCategoryChip(
            context,
            category.name,
            selectedCategory == category.name,
            () => context.read<TodoBloc>().add(
              TodosFilteredByCategory(category.name),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(label),
          backgroundColor:
              isSelected ? Theme.of(context).colorScheme.primary : null,
          labelStyle: TextStyle(color: isSelected ? Colors.white : null),
        ),
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(todo.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty) Text(todo.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(todo.category),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.cloud_download, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                const Text(
                  'jsonplaceholder',
                  style: TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: todo.isCompleted ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
