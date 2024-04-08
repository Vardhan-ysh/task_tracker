// This file contains the Task model class, which is a HiveObject.

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart'; // Generated Hive adapter

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  String title;

  @HiveField(2)
  String id;

  @HiveField(3)
  bool isComplete;

  Task({
    required this.description,
    required this.title,
    this.isComplete = false,
    required this.id,
  });
}
