import 'package:ai_personal_trainer/model/workout.dart';
import 'package:ai_personal_trainer/widgets/workout_day_view.dart';
import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage(
      {super.key,
      required this.workout,
      required this.index,
      required this.removeWorkout});

  final Workout workout;
  final int index;
  final Function removeWorkout;

  @override
  Widget build(BuildContext context) {
    final scaffoldStateKey = GlobalKey<ScaffoldState>();

    return DefaultTabController(
      initialIndex: 0,
      length: workout.days.length,
      child: Scaffold(
        key: scaffoldStateKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
                onPressed: () => scaffoldStateKey.currentState!.openEndDrawer(),
                icon: Icon(Icons.wysiwyg))
          ],
          title: Text(workout.name),
          bottom: TabBar(
            tabs: workout.days
                .map((d) => Tab(
                      text: d.day,
                    ))
                .toList(),
          ),
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: Icon(Icons.wysiwyg),
                tileColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(
                  'Workout Options',
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  'Delete workout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  removeWorkout(index);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              )
            ],
          ),
        ),
        body: TabBarView(
          children: workout.days
              .map((d) => WorkoutDayView(workout: workout, day: d))
              .toList(),
        ),
      ),
    );
  }
}
