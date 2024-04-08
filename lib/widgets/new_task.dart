import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_tracker/models/task.dart';
// import 'package:task_tracker/models/task.dart';
import 'package:task_tracker/providers/tasks_provider.dart';
import 'package:http/http.dart' as http;

//this file is to implement modal bottom sheet to add new task

class NewTask extends ConsumerStatefulWidget {
  const NewTask({required this.addTask, super.key});

  final void Function() addTask;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewTaskState();
}

class _NewTaskState extends ConsumerState<NewTask> {
  //creating text editing controllers for title and description

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  //disposing the controllers

  var _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  //method to save the task
  //if the title or description is empty, show an alert dialog
  //else, call the addTask method from the TasksNotifier to add the task

  void _saveTask() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      showDialog(
        context: context,

        //creating an alert dialog to show the error message

        builder: (context) => AlertDialog(
          title: Center(
            child: Text(
              "Invalid Input".toUpperCase(),
              style: GoogleFonts.robotoCondensed(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          content: Text(
            "Input fields cannot be empty. Please enter a title and description."
                .toUpperCase(),
            style: GoogleFonts.robotoCondensed(
              // fontSize: 15,

              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
          alignment: Alignment.bottomCenter,
        ),
      );
    } else {
      //getting the title and description from the text editing controllers
      //calling the addTask method from the TasksNotifier to add the task

      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
        "task-tracker-49523-default-rtdb.firebaseio.com",
        "/tasks.json",
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(
          {
            "title": title,
            "description": description,
            "isComplete": false,
          },
        ),
      );

      widget.addTask();

      //getting the TasksNotifier to call the addTask method

      final tasksNotifier = ref.watch(tasksProvider.notifier);
      tasksNotifier.addTask(
        Task(
          description: description,
          title: title,
          id: json.decode(response.body)['name'],
          isComplete: false,
        ),
      );

      //closing the modal bottom sheet

      if (!context.mounted) return;

      Navigator.of(context).pop();

      widget.addTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    //getting the keyboard space to adjust the padding of the container
    //returning a layout builder to get the constraints of the screen

    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: keyboardSpace + 16,
        ),

        //creating a scrollable column to add the title, description, and add task button

        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                '--- New Task ---',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              const SizedBox(height: 16),

              //creating text fields for title and description

              TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                maxLength: 50,
                controller: _titleController,
              ),
              const SizedBox(height: 16),
              TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLength: 200,
                controller: _descriptionController,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _isSending
                    ? null
                    : () {
                        //calling the _saveTask method to save the task
                        _saveTask();
                      },
                child: _isSending
                    ? const Text('Saving...')
                    : const Text('Add Task'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
