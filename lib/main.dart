import 'dart:io';

import 'package:ai_personal_trainer/model/workout_day.dart';
import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/service/get_response.dart';
import 'package:ai_personal_trainer/service/workout_storage.dart';
import 'package:ai_personal_trainer/model/workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('theme') == null) {
      return;
    }
    if (prefs.getString('theme') == 'dark') {
      setState(() {
        _themeMode = ThemeMode.dark;
      });
    }
    if (prefs.getString('theme') == 'light') {
      setState(() {
        _themeMode = ThemeMode.light;
      });
    }
  }

  void toggleTheme() async {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    final prefs = await SharedPreferences.getInstance();

    switch (_themeMode) {
      case ThemeMode.system:
        setState(() {
          if (isDarkMode) {
            _themeMode = ThemeMode.light;
            prefs.setString('theme', 'light');
          } else {
            _themeMode = ThemeMode.dark;
            prefs.setString('theme', 'dark');
          }
        });
      case ThemeMode.light:
        setState(() {
          _themeMode = ThemeMode.dark;
          prefs.setString('theme', 'dark');
        });
      default:
        setState(() {
          _themeMode = ThemeMode.light;
          prefs.setString('theme', 'light');
        });
    }
  }

  IconData getCorrectIcon() {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    IconData icon;
    switch (_themeMode) {
      case ThemeMode.system:
        if (isDarkMode) {
          icon = Icons.light_mode;
        } else {
          icon = Icons.dark_mode;
        }
      case ThemeMode.light:
        icon = Icons.dark_mode;
      default:
        icon = Icons.light_mode;
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'AI PersonalTrainer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo, brightness: Brightness.dark),
        ),
        themeMode: _themeMode,
        home: MyHomePage(
          storage: WorkoutStorage(),
        ),
      ),
    );
  }
}

extension on State<MyApp> {}

class MyAppState extends ChangeNotifier {
  WorkoutRequest request = WorkoutRequest([], [], [], '0h00m');

  void updateRequest(WorkoutRequest newReq) {
    request = newReq;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.storage});

  final WorkoutStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  List<Workout> workouts = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.storage.readWorkouts().then((data) {
      if (data.isNotEmpty) {
        setState(() {
          workouts = data;
        });
      }
    });
  }

  Future<File> addWorkout(Workout workout) {
    setState(() {
      workouts.add(workout);
    });

    return widget.storage.writeWorkouts(workouts);
  }

  Future<File> removeWorkout(int index) {
    setState(() {
      workouts.removeAt(index);
    });

    return widget.storage.writeWorkouts(workouts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('AI Personal Trainer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
              icon: Icon(Icons.settings))
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              tileColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            ListTile(
              leading: Icon(MyApp.of(context).getCorrectIcon()),
              title: Text('Change theme'),
              onTap: () => MyApp.of(context).toggleTheme(),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () => showAboutDialog(
                  context: context,
                  applicationVersion: '1.0.0',
                  children: [
                    Wrap(
                      children: [
                        Text('Created by '),
                        InkWell(
                          child: Text('Torelli'),
                          onTap: () {
                            try {
                              launchUrlString('https://github.com/Torelli',
                                  mode: LaunchMode.externalApplication);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Couldn\'t open the browser :(')));
                            }
                          },
                        )
                      ],
                    )
                  ]),
            )
          ],
        ),
      ),
      body: workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('You don\'t have any workouts yet')],
              ),
            )
          : ListView(
              children: workouts
                  .asMap()
                  .entries
                  .map((w) => WorkoutCard(
                        workout: w.value,
                        index: w.key,
                        removeWorkout: removeWorkout,
                      ))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createWorkoutForm(context),
        tooltip: 'New Workout',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> createWorkoutForm(BuildContext context) {
    return showDialog(
        barrierDismissible: index == 4 ? false : true,
        context: context,
        builder: (context) {
          var canContinue = false;
          var appState = context.watch<MyAppState>();
          var days = appState.request.days;
          var goals = appState.request.goals;
          var modalities = appState.request.modalities;
          var duration = appState.request.duration;

          return StatefulBuilder(builder: (context, setState) {
            Widget formStep;
            switch (index) {
              case 0:
                formStep = WorkoutDaysForm();
                canContinue = days.isNotEmpty;
              case 1:
                formStep = WorkoutGoalsForm();
                canContinue = goals.isNotEmpty;
              case 2:
                formStep = WorkoutModalitiesForm();
                canContinue = modalities.isNotEmpty;
              case 3:
                formStep = WorkoutDurationForm();
                canContinue = duration != '0h00m';
              case 4:
                formStep = Center(child: CircularProgressIndicator());
              default:
                formStep = Placeholder();
            }
            return AlertDialog(
              title: index < 4 ? Text('New Workout') : SizedBox.shrink(),
              insetPadding: EdgeInsets.all(10),
              backgroundColor: index == 4
                  ? Colors.transparent
                  : Theme.of(context).dialogBackgroundColor,
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width - 100,
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: formStep,
                ),
              ),
              actions: [
                index > 0 && index < 4
                    ? ElevatedButton(
                        onPressed: () {
                          setState(() {
                            index--;
                          });
                        },
                        child: Text('Back'))
                    : SizedBox.shrink(),
                index < 4
                    ? ElevatedButton(
                        onPressed: index < 3 && canContinue
                            ? () {
                                setState(() {
                                  index++;
                                });
                              }
                            : index == 3 && canContinue
                                ? () async {
                                    setState(() {
                                      index = 4;
                                    });
                                    try {
                                      var newWorkout =
                                          await getResponse(appState.request);
                                      addWorkout(newWorkout);
                                      if (context.mounted) {
                                        setState(() {
                                          index = 0;
                                          appState.updateRequest(WorkoutRequest(
                                              [], [], [], "0h00m"));
                                        });
                                        Navigator.pop(context, 'Success');
                                      }
                                    } catch (e) {
                                      appState.updateRequest(
                                          WorkoutRequest([], [], [], "0h00m"));
                                      if (context.mounted) {
                                        setState(() {
                                          index = 0;
                                          appState.updateRequest(WorkoutRequest(
                                              [], [], [], "0h00m"));
                                        });
                                        Navigator.pop(context, 'Fail');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Something went wrong, try again later')));
                                      }
                                    }
                                  }
                                : null,
                        child: Text(index < 3 ? 'Next' : 'Generate workout'))
                    : SizedBox.shrink(),
              ],
            );
          });
        });
  }
}

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
                'Modalities: ',
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
                  'Goals: ',
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
                  'Duration: ',
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
