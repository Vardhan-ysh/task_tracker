import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker/models/task.dart';
import 'package:task_tracker/providers/tasks_provider.dart';
import 'package:http/http.dart' as http;

// creating a TaskCard widget to display the task details

class TaskCard extends ConsumerWidget {
  const TaskCard({
    required this.task,
    super.key,
    required this.deleteTask,
    required this.updateTask,
  });

  final void Function(Task task) updateTask;

  final void Function(String taskId) deleteTask;

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // returning a Dismissible widget to enable swipe to delete functionality

    return Dismissible(
      key: ValueKey(task.id),
      onDismissed: (direction) async {
        // calling the deleteTask method from the TasksNotifier to delete the task

        final url = Uri.https(
          "task-tracker-49523-default-rtdb.firebaseio.com",
          "/tasks/${task.id}.json",
        );

        http.delete(url);

        deleteTask(task.id!);

        ref.watch(tasksProvider.notifier).deleteTask(task.id!);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
        // creating a card to display the task details
        child: Card(
          child: ListTile(
            leading: Checkbox(
              value: task.isComplete,
              onChanged: (value) async {
                // calling the markTask method from the TasksNotifier to mark the task as complete

                updateTask(task);

                ref.watch(tasksProvider.notifier).markTask(task.id!);
              },
            ),

            // displaying the task title and description

            title: Text(
              task.title!,
              style: TextStyle(
                fontWeight: FontWeight.bold,

                // adding a line-through decoration to the text if the task is complete

                decoration: task.isComplete!
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationThickness: 3.5,
                decorationColor:
                    Theme.of(context).colorScheme.background.withOpacity(0.8),
              ),
            ),
            subtitle: Text(task.description!),
          ),
        ),
      ),
    );
  }
}
