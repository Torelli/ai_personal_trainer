import 'package:ai_personal_trainer/model/exercise.dart';

class WorkoutDay {
  late String day;
  late String duration;
  late List<Exercise> exercises;

  WorkoutDay(
      {required this.day, required this.duration, required this.exercises});

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    var exercisesJson = json['exercises'] as List;
    List<Exercise> exercises =
        exercisesJson.map((v) => Exercise.fromJson(v)).toList();
    return WorkoutDay(
        day: json['day'] as String,
        duration: json['duration'] as String,
        exercises: exercises);
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'duration': duration,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}
