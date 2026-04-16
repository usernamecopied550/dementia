import '../models/medication.dart';
import '../models/task.dart';

class AppData {
  // ✅ ADD DATA HERE (THIS WAS MISSING)
  static List<Medication> medications = [
    Medication(
      name: "Paracetamol",
      time: "10:00 AM",
      taken: false,
    ),
    Medication(
      name: "Vitamin D",
      time: "6:00 PM",
      taken: false,
    ),
  ];

  static List<Task> tasks = [
    Task(title: "Take Medication", isDone: false),
    Task(title: "Eat Breakfast", isDone: true),
    Task(title: "Go for a walk", isDone: false),
    Task(title: "Drink Water", isDone: false),
    Task(title: "Groceries", isDone: false),
  ];
}