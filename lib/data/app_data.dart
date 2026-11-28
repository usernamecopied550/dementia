import '../models/contact.dart';
import '../models/medication.dart';
import '../models/task.dart';

class AppData {
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

  // People the patient knows (added by the caregiver on the Contacts screen).
  // NOTE: stored in memory for now — they reset when the app restarts.
  static List<Contact> contacts = [];
}
