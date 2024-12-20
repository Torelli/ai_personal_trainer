import 'package:ai_personal_trainer/model/workout.dart';
import 'package:ai_personal_trainer/widgets/workout_page.dart';
import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard(
      {super.key,
      required this.workout,
      required this.index,
      required this.removeWorkout});

  final Workout workout;
  final int index;
  final Function removeWorkout;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Card(
        child: ListTile(
          title: Text(workout.name),
          subtitle: Text(
            workout.modalities.join(', '),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return WorkoutPage(
                workout: workout,
                index: index,
                removeWorkout: removeWorkout,
              );
            }));
          },
        ),
      ),
    );
  }
}
