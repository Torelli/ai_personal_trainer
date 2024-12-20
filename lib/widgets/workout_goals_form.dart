import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/service/app_localizations.dart';
import 'package:ai_personal_trainer/service/my_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutGoalsForm extends StatefulWidget {
  const WorkoutGoalsForm({super.key});

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
        Text(AppLocalizations.of(context).translate('selectGoals')),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('muscleGain')),
              value: goals.contains(
                  AppLocalizations.of(context).translate('muscleGain')),
              onChanged: (bool? value) => toggleGoal(
                  AppLocalizations.of(context).translate('muscleGain'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('fatLoss')),
              value: goals
                  .contains(AppLocalizations.of(context).translate('fatLoss')),
              onChanged: (bool? value) => toggleGoal(
                  AppLocalizations.of(context).translate('fatLoss'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context)
                  .translate('flexibilityMobility')),
              value: goals.contains(AppLocalizations.of(context)
                  .translate('flexibilityMobility')),
              onChanged: (bool? value) => toggleGoal(
                  AppLocalizations.of(context)
                      .translate('flexibilityMobility'))),
        ),
        Card(
          child: CheckboxListTile(
              title:
                  Text(AppLocalizations.of(context).translate('agilitySpeed')),
              value: goals.contains(
                  AppLocalizations.of(context).translate('agilitySpeed')),
              onChanged: (bool? value) => toggleGoal(
                  AppLocalizations.of(context).translate('agilitySpeed'))),
        ),
      ],
    );
  }
}
