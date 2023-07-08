import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class Todo {
  final int id;
  String title;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}

class TodoProvider extends ChangeNotifier {
  final String apiUrl =
      'http://localhost:8000/api'; // Replace with your Laravel API URL
  late Dio _dio;

  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  TodoProvider() {
    _dio = Dio();
  }

  Future<void> fetchTodos() async {
    try {
      final response = await _dio.get('$apiUrl/todos');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        _todos = responseData.map((item) => Todo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch todos');
      }
    } catch (error) {
      throw Exception('Failed to fetch todos: $error');
    }
    notifyListeners();
  }

  Future<void> createTodo({
    required String title,
  }) async {
    try {
      final response = await _dio.post('$apiUrl/todos', data: {'title': title});

      if (response.statusCode == 201) {
        final dynamic responseData = response.data;
        Todo newTodo = Todo.fromJson(responseData);
        _todos.add(newTodo);
      } else {
        throw Exception('Failed to create todo');
      }
    } catch (error) {
      throw Exception('Failed to create todo');
    }
    notifyListeners();
  }

  Future<void> updateTodo({
    required int todoId,
    required String title,
    required bool completed,
  }) async {
    try {
      final response = await _dio.put('$apiUrl/todos/$todoId',
          data: {'title': title, 'completed': completed.toString()});

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        Todo updatedTodo = Todo.fromJson(responseData);
        int index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
        if (index != -1) {
          _todos[index] = updatedTodo;
        }
      } else {
        throw Exception('Failed to update todo');
      }
    } catch (error) {
      throw Exception('Failed to update todo');
    }
    notifyListeners();
  }

  Future<void> deleteTodo({
    required int todoId,
  }) async {
    try {
      final response = await _dio.delete('$apiUrl/todos/$todoId');

      if (response.statusCode == 200) {
        _todos.removeWhere((todo) => todo.id == todoId);
      } else {
        throw Exception('Failed to delete todo');
      }
    } catch (error) {
      throw Exception('Failed to delete todo');
    }
    notifyListeners();
  }
}
