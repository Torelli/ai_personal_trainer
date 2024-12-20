import 'package:ai_personal_trainer/model/workout_day.dart';

class Workout {
  late String name;
  late List<String> goals;
  late List<String> modalities;
  late List<WorkoutDay> days;

  Workout(
      {required this.name,
      required this.goals,
      required this.modalities,
      required this.days});

  factory Workout.fromJson(
      Map<String, dynamic> json, List<String> goals, List<String> modalities) {
    var daysObjsJson = json['days'] as List;
    List<WorkoutDay> days =
        daysObjsJson.map((v) => WorkoutDay.fromJson(v)).toList();

    return Workout(
        name: json['name'] as String,
        goals: goals,
        modalities: modalities,
        days: days);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'goals': goals,
        'modalities': modalities,
        'days': days.map((day) => day.toJson()).toList()
      };
}
