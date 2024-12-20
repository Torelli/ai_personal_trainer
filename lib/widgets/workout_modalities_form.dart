import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/service/app_localizations.dart';
import 'package:ai_personal_trainer/service/my_app_state.dart';
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
        Text(AppLocalizations.of(context).translate('selectModalities')),
        Card(
          child: CheckboxListTile(
              title:
                  Text(AppLocalizations.of(context).translate('calisthenics')),
              value: modalities.contains(
                  AppLocalizations.of(context).translate('calisthenics')),
              onChanged: (bool? value) => toggleModality(
                  AppLocalizations.of(context).translate('calisthenics'))),
        ),
        Card(
          child: CheckboxListTile(
              title:
                  Text(AppLocalizations.of(context).translate('weightLifting')),
              value: modalities.contains(
                  AppLocalizations.of(context).translate('weightLifting')),
              onChanged: (bool? value) => toggleModality(
                  AppLocalizations.of(context).translate('weightLifting'))),
        ),
        Card(
          child: CheckboxListTile(
              title: Text(AppLocalizations.of(context).translate('aerobics')),
              value: modalities
                  .contains(AppLocalizations.of(context).translate('aerobics')),
              onChanged: (bool? value) => toggleModality(
                  AppLocalizations.of(context).translate('aerobics'))),
        ),
      ],
    );
  }
}
