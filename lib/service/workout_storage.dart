import 'dart:convert';
import 'dart:io';

import 'package:ai_personal_trainer/model/workout.dart';
import 'package:path_provider/path_provider.dart';

class WorkoutStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/workouts.json');
  }

  Future<List<Workout>> readWorkouts() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      var jsonMap = jsonDecode(contents);

      List<Workout> workouts = jsonMap
          .map((workout) => Workout.fromJson(
              workout,
              workout['goals'].cast<String>(),
              workout['modalities'].cast<String>()))
          .toList()
          .cast<Workout>();

      return workouts;
    } catch (e) {
      return [];
    }
  }

  Future<File> writeWorkouts(List<Workout> workouts) async {
    final file = await _localFile;

    return file.writeAsString(jsonEncode(workouts));
  }
}
