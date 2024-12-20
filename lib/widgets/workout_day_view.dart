import 'package:ai_personal_trainer/model/workout.dart';
import 'package:ai_personal_trainer/model/workout_day.dart';
import 'package:ai_personal_trainer/service/app_localizations.dart';
import 'package:flutter/material.dart';

class WorkoutDayView extends StatefulWidget {
  const WorkoutDayView({super.key, required this.workout, required this.day});

  final Workout workout;
  final WorkoutDay day;

  @override
  State<WorkoutDayView> createState() => _WorkoutDayViewState();
}

class _WorkoutDayViewState extends State<WorkoutDayView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(children: [
              Text(
                AppLocalizations.of(context).translate('modalities'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.workout.modalities.join(', '),
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ]),
            Wrap(
              children: [
                Text(
                  AppLocalizations.of(context).translate('goals'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.workout.goals.join(', '),
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
              ],
            ),
            Wrap(
              children: [
                Text(
                  AppLocalizations.of(context).translate('duration'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.day.duration,
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  widget.day.exercises[index].isExpanded = isExpanded;
                });
              },
              children: widget.day.exercises
                  .map((e) => ExpansionPanel(
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Text(e.name),
                        );
                      },
                      body: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                Text(
                                  'Reps: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(e.reps)
                              ],
                            ),
                            Text(e.description)
                          ],
                        ),
                      ),
                      isExpanded: e.isExpanded))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
