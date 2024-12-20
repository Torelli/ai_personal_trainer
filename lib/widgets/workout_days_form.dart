import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/service/app_localizations.dart';
import 'package:ai_personal_trainer/service/my_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutDaysForm extends StatefulWidget {
  const WorkoutDaysForm({super.key});

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
        Text(AppLocalizations.of(context).translate('selectDays')),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('monday')),
              value: days
                  .contains(AppLocalizations.of(context).translate('monday')),
              onChanged: (bool? value) =>
                  toggleDay(AppLocalizations.of(context).translate('monday'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('tuesday')),
              value: days
                  .contains(AppLocalizations.of(context).translate('tuesday')),
              onChanged: (bool? value) =>
                  toggleDay(AppLocalizations.of(context).translate('tuesday'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('wednesday')),
              value: days.contains(
                  AppLocalizations.of(context).translate('wednesday')),
              onChanged: (bool? value) => toggleDay(
                  AppLocalizations.of(context).translate('wednesday'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('thursday')),
              value: days
                  .contains(AppLocalizations.of(context).translate('thursday')),
              onChanged: (bool? value) => toggleDay(
                  AppLocalizations.of(context).translate('thursday'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('friday')),
              value: days
                  .contains(AppLocalizations.of(context).translate('friday')),
              onChanged: (bool? value) =>
                  toggleDay(AppLocalizations.of(context).translate('friday'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('saturday')),
              value: days
                  .contains(AppLocalizations.of(context).translate('saturday')),
              onChanged: (bool? value) => toggleDay(
                  AppLocalizations.of(context).translate('saturday'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('sunday')),
              value: days
                  .contains(AppLocalizations.of(context).translate('sunday')),
              onChanged: (bool? value) =>
                  toggleDay(AppLocalizations.of(context).translate('sunday'))),
        )
      ],
    );
  }
}
