import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/widgets/my_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutModalitiesForm extends StatefulWidget {
  @override
  State<WorkoutModalitiesForm> createState() => _WorkoutModalitiesFormState();
}

class _WorkoutModalitiesFormState extends State<WorkoutModalitiesForm> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var modalities = appState.request.modalities;
    toggleModality(String value) {
      WorkoutRequest newReq = WorkoutRequest(
          appState.request.days,
          appState.request.goals,
          appState.request.modalities,
          appState.request.duration);
      if (newReq.modalities.contains(value)) {
        newReq.modalities.removeWhere((item) => item == value);
        appState.updateRequest(newReq);
        return;
      }
      newReq.modalities.add(value);
      appState.updateRequest(newReq);
    }

    return Column(
      children: [
        Text('Select the modalities you want to train'),
        Card(
          child: CheckboxListTile(
              title: Text('Calisthenics'),
              value: modalities.contains('Calisthenics'),
              onChanged: (bool? value) => toggleModality('Calisthenics')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Weight Lifting'),
              value: modalities.contains('Weight Lifting'),
              onChanged: (bool? value) => toggleModality('Weight Lifting')),
        ),
        Card(
          child: CheckboxListTile(
              title: Text('Aerobics'),
              value: modalities.contains('Aerobics'),
              onChanged: (bool? value) => toggleModality('Aerobics')),
        ),
      ],
    );
  }
}
