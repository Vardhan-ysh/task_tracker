import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker/models/task.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_tracker/providers/tasks_provider.dart';
import 'package:task_tracker/widgets/new_task.dart';
import 'package:task_tracker/widgets/task_card.dart';
import 'package:http/http.dart' as http;

// implementing the main screen of the app

class TasksMainScreen extends ConsumerStatefulWidget {
  const TasksMainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TasksMainScreenState();
}

class _TasksMainScreenState extends ConsumerState<TasksMainScreen> {
  List<Task> tasks = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    _loadItems();

    super.initState();
  }

  void _deleteTask(String taskId) {
    setState(() {
      tasks.removeWhere((task) => task.id == taskId);
    });
  }

  Future<void> updateTask(Task task) async {
    final url = Uri.https(
      "task-tracker-49523-default-rtdb.firebaseio.com",
      "/tasks/${task.id}.json",
    );

    bool change = task.isComplete;
    change = !change;

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(
        {
          "isComplete": change,
        },
      ),
    );

    setState(() {
      task.isComplete = change;
    });

    print(response.body);
  }

  void _loadItems() async {
    final url = Uri.https(
      "task-tracker-49523-default-rtdb.firebaseio.com",
      "/tasks.json",
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Loading failed! Please try again later.';
        _isLoading = false;
      });
      return;
    }

    if (response.body.isEmpty) {
      tasks = [];
      _isLoading = false;
      return;
    }

    final Map<String, dynamic> listData = json.decode(response.body);

    final List<Task> loadedItems = [];

    for (final item in listData.entries) {
      loadedItems.add(Task(
        title: item.value['title'],
        description: item.value['description'],
        isComplete: item.value['isComplete'],
        id: item.key,
      ));
    }

    setState(() {
      tasks = loadedItems;
      _isLoading = false;
    });
  }

  void addItem() async {
    _loadItems();

    // print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    // creating an empty screen widget to show when there are no tasks

    Widget emptyScreen = const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Your tasks will be shown here!',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Try adding some by clicking the "+" icon below',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ));

    if (_isLoading && tasks.isNotEmpty) {
      emptyScreen = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      emptyScreen = Center(
        child: Text(_error!),
      );
    }

    // getting the tasks from the provider

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Tracker',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),

      // floating action button to add a new task

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            useSafeArea: true,
            builder: (BuildContext context) {
              return NewTask(
                addTask: addItem,
              );
            },
          );

          final url = Uri.https(
            "task-tracker-49523-default-rtdb.firebaseio.com",
            "/tasks.json",
          );
        },
        child: const Icon(Icons.add),
      ),

      // body of the app show en empty screen if there are no tasks
      // else show the list of tasks using a list view builder and TaskCard widget
      body: tasks.isEmpty
          ? emptyScreen
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  deleteTask: (taskId) => _deleteTask(taskId),
                  updateTask: (task) => updateTask(task),
                );
              },
            ),
    );
  }
}
