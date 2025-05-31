import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/todo_bloc.dart';
import 'presentation/pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  log('Запуск приложения ToDo');
  log('API: https://jsonplaceholder.typicode.com');
  
  log('Инициализация зависимостей...');
  await di.init();
  log('Зависимости инициализированы');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    log('Сборка корневого виджета приложения');
    return BlocProvider(
      create: (_) {
        log('Создание TodoBloc');
        return di.sl<TodoBloc>();
      },
      child: MaterialApp(
        title: 'ToDo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
