class Medication {
  int? id;
  String name;
  String time;
  bool taken;

  Medication({
    this.id,
    required this.name,
    required this.time,
    this.taken = false,
  });
}

