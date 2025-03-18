import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _tasks = [];

  List<Map<String, dynamic>> get tasks => _tasks;

  TaskProvider() {
    _fetchTasks();
    _listenForRealtimeUpdates();
  }

  Future<void> _fetchTasks() async {
    final response = await _supabase.from('tasks').select().execute();
    if (response.error == null) {
      _tasks = List<Map<String, dynamic>>.from(response.data);
      notifyListeners();
    }
  }

  void _listenForRealtimeUpdates() {
    _supabase.from('tasks').on(SupabaseEventTypes.all, (payload) {
      _fetchTasks();
    }).subscribe();
  }

  Future<void> addTask(String name, String description, String assignee) async {
    final response = await _supabase.from('tasks').insert([
      {
        'name': name,
        'description': description,
        'assignee': assignee,
        'owner': assignee,
        'createdAt': DateTime.now().toIso8601String(),
        'isSelected': false
      }
    ]).execute();
    if (response.error == null) {
      _tasks.add(response.data[0]);
      notifyListeners();
    }
  }

  Future<void> updateTask(Map<String, dynamic> task, String name, String description, String assignee) async {
    final response = await _supabase.from('tasks').update({
      'name': name,
      'description': description,
      'owner': assignee,
    }).eq('id', task['id']).execute();
    if (response.error == null) {
      task['name'] = name;
      task['description'] = description;
      task['owner'] = assignee;
      notifyListeners();
    }
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    final response = await _supabase.from('tasks').delete().eq('id', task['id']).execute();
    if (response.error == null) {
      _tasks.remove(task);
      notifyListeners();
    }
  }
}
