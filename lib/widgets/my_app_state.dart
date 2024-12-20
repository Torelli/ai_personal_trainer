import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  WorkoutRequest request = WorkoutRequest([], [], [], '0h00m');

  void updateRequest(WorkoutRequest newReq) {
    request = newReq;
    notifyListeners();
  }
}
