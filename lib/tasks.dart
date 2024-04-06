import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_tracker/providers/tasks_provider.dart';
import 'package:task_tracker/widgets/new_task.dart';
import 'package:task_tracker/widgets/task_card.dart';

// implementing the main screen of the app

class TasksMainScreen extends ConsumerStatefulWidget {
  const TasksMainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TasksMainScreenState();
}

class _TasksMainScreenState extends ConsumerState<TasksMainScreen> {
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

    // getting the tasks from the provider

    final tasks = ref.watch(tasksProvider);
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            useSafeArea: true,
            builder: (BuildContext context) {
              return const NewTask();
            },
          );
        },
        child: const Icon(Icons.add),
      ),

      // body of the app show en empty screen if there are no tasks
      // else show the list of tasks using a list view builder and TaskCard widget
      body: ref.read(tasksProvider).isEmpty
          ? emptyScreen
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(task: task);
              },
            ),
    );
  }
}
