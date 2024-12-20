import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/widgets/my_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutDaysForm extends StatefulWidget {
  @override
  State<WorkoutDaysForm> createState() => _WorkoutDaysFormState();
}

class _WorkoutDaysFormState extends State<WorkoutDaysForm> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var days = appState.request.days;
    toggleDay(String value) {
      WorkoutRequest newReq = WorkoutRequest(
          appState.request.days,
          appState.request.goals,
          appState.request.modalities,
          appState.request.duration);
      if (newReq.days.contains(value)) {
        newReq.days.removeWhere((item) => item == value);
        appState.updateRequest(newReq);
        return;
      }
      newReq.days.add(value);
      appState.updateRequest(newReq);
    }

    return Column(
      children: [
        Text('Select the days you want to train'),
        Card(
          child: CheckboxListTile(
              title: Text('Monday'),
              value: days.contains('Monday'),
              onChanged: (bool? value) => toggleDay('Monday')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Tuesday'),
              value: days.contains('Tuesday'),
              onChanged: (bool? value) => toggleDay('Tuesday')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Wednesday'),
              value: days.contains('Wednesday'),
              onChanged: (bool? value) => toggleDay('Wednesday')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Thursday'),
              value: days.contains('Thursday'),
              onChanged: (bool? value) => toggleDay('Thursday')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Friday'),
              value: days.contains('Friday'),
              onChanged: (bool? value) => toggleDay('Friday')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Saturday'),
              value: days.contains('Saturday'),
              onChanged: (bool? value) => toggleDay('Saturday')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Sunday'),
              value: days.contains('Sunday'),
              onChanged: (bool? value) => toggleDay('Sunday')),
        )
      ],
    );
  }
}
