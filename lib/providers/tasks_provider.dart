import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_tracker/models/task.dart';
import 'package:http/http.dart' as http;

// creating a provider to open the tasks box
// this provider will return a Future<Box<Task>> object
// which will be used to open the tasks box
// The box will be used to store the tasks to local memory

final tasksBoxProvider = FutureProvider<Box<Task>>((ref) async {
  return await Hive.openBox<Task>('tasks');
});

// creating a provider to provide the tasks list

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final box = ref.watch(tasksBoxProvider).maybeWhen(
        data: (box) => box,
        orElse: () => null,
      );

  // returning the TasksNotifier with the tasks box
  // this will be used to add, delete, and mark tasks

  return TasksNotifier(box);
});

// creating a TasksNotifier class to manage the tasks

class TasksNotifier extends StateNotifier<List<Task>> {
  @override

  // disposing the box when the notifier is disposed

  void dispose() {
    box?.close();
    super.dispose();
  }

  final Box<Task>? box;

  // initializing the TasksNotifier with the tasks box

  TasksNotifier(this.box) : super(box?.values.toList() ?? []);

  // method to add a new task to the box

  void addTask(Task task) {
    final newTask = Task(
      title: task.title,
      description: task.description,
      isComplete: false,
      id: task.id,
    );
    box?.put(newTask.id, newTask);
    state = box?.values.toList() ?? [];
  }

  // method to delete a task from the box

  void deleteTask(String taskId) {
    box?.delete(taskId);
    state = box?.values.toList() ?? [];
  }

  // method to mark a task as complete or incomplete

  void markTask(String taskId) async {
    // print("😊😊");
    // print(taskId);

    final task = box?.get(taskId);
    // print(!task!.isComplete);
    if (task != null) {
      task.isComplete = !task.isComplete;
      box?.put(taskId, task);
      state = box!.values.toList();
    }

    // print(response.statusCode);
    // print("😊😊");
  }
}
