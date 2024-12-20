class Exercise {
  late String name;
  late String description;
  late String reps;
  bool isExpanded = false;

  Exercise({required this.name, required this.description, required this.reps});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
        name: json['name'] as String,
        description: json['description'] as String,
        reps: json['reps'] as String);
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'description': description, 'reps': reps};
}
