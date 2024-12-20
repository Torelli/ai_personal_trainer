import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/widgets/my_app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WorkoutDurationForm extends StatefulWidget {
  @override
  State<WorkoutDurationForm> createState() => _WorkoutDurationFormState();
}

class _WorkoutDurationFormState extends State<WorkoutDurationForm> {
  var currentDuration = ['0', '00'];
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var duration = appState.request.duration;
    changeDuration() {
      var hours = currentDuration[0].isEmpty ? '0' : currentDuration[0];
      var minutes = currentDuration[1].isEmpty ? '00' : currentDuration[1];
      WorkoutRequest newReq = WorkoutRequest(
          appState.request.days,
          appState.request.goals,
          appState.request.modalities,
          appState.request.duration);
      newReq.duration = '${hours}h${minutes}m';
      appState.updateRequest(newReq);
    }

    return Column(
      children: [
        Text('Select the maximum duration of the workout'),
        Wrap(
          children: [
            SizedBox(
              width: 100,
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1)
                ],
                initialValue: duration.split('h')[0],
                decoration: InputDecoration(labelText: 'Hours'),
                onChanged: (value) => setState(() {
                  currentDuration[0] = value;
                  changeDuration();
                }),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2)
                ],
                initialValue: duration.split('h')[1].substring(0, 2),
                decoration: InputDecoration(labelText: 'Minutes'),
                onChanged: (value) => setState(() {
                  currentDuration[1] = value;
                  changeDuration();
                }),
              ),
            ),
          ],
        )
      ],
    );
  }
}
