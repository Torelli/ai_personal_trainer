import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/widgets/my_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutGoalsForm extends StatefulWidget {
  @override
  State<WorkoutGoalsForm> createState() => _WorkoutGoalsFormState();
}

class _WorkoutGoalsFormState extends State<WorkoutGoalsForm> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var goals = appState.request.goals;
    toggleGoal(String value) {
      WorkoutRequest newReq = WorkoutRequest(
          appState.request.days,
          appState.request.goals,
          appState.request.modalities,
          appState.request.duration);
      if (newReq.goals.contains(value)) {
        newReq.goals.removeWhere((item) => item == value);
        appState.updateRequest(newReq);
        return;
      }
      newReq.goals.add(value);
      appState.updateRequest(newReq);
    }

    return Column(
      children: [
        Text('Select your goals'),
        Card(
          child: CheckboxListTile(
              title: Text('Muscle Gain'),
              value: goals.contains('Muscle Gain'),
              onChanged: (bool? value) => toggleGoal('Muscle Gain')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Fat Loss'),
              value: goals.contains('Fat Loss'),
              onChanged: (bool? value) => toggleGoal('Fat Loss')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Improve Flexibility and Mobility'),
              value: goals.contains('Improve Flexibility and Mobility'),
              onChanged: (bool? value) =>
                  toggleGoal('Improve Flexibility and Mobility')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Improve Agility and Speed'),
              value: goals.contains('Improve Agility and Speed'),
              onChanged: (bool? value) =>
                  toggleGoal('Improve Agility and Speed')),
        ),
      ],
    );
  }
}
