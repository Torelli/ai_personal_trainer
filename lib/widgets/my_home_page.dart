import 'dart:io';

import 'package:ai_personal_trainer/main.dart';
import 'package:ai_personal_trainer/model/languages.dart';
import 'package:ai_personal_trainer/model/workout.dart';
import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/service/app_language.dart';
import 'package:ai_personal_trainer/service/app_localizations.dart';
import 'package:ai_personal_trainer/service/get_response.dart';
import 'package:ai_personal_trainer/service/workout_storage.dart';
import 'package:ai_personal_trainer/service/my_app_state.dart';
import 'package:ai_personal_trainer/widgets/workout_card.dart';
import 'package:ai_personal_trainer/widgets/workout_days_form.dart';
import 'package:ai_personal_trainer/widgets/workout_duration_form.dart';
import 'package:ai_personal_trainer/widgets/workout_goals_form.dart';
import 'package:ai_personal_trainer/widgets/workout_modalities_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.storage});

  final WorkoutStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  List<Workout> workouts = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    var appLanguage = Provider.of<AppLanguage>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('AI Personal Trainer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
              icon: const Icon(Icons.settings))
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context).translate('settings')),
              tileColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            ListTile(
              leading: Icon(MyApp.of(context).getCorrectIcon()),
              title:
                  Text(AppLocalizations.of(context).translate('changeTheme')),
              onTap: () => MyApp.of(context).toggleTheme(),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                  AppLocalizations.of(context).translate('changeLanguage')),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    // ignore: no_leading_underscores_for_local_identifiers
                    var _selectedLanguage =
                        appLanguage.appLocal.toString() == 'en'
                            ? Languages.us
                            : Languages.pt;

                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)
                            .translate('changeLanguage')),
                        insetPadding: const EdgeInsets.all(10),
                        content: SingleChildScrollView(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 100,
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(AppLocalizations.of(context)
                                      .translate('us_EN')),
                                  leading: Radio<Languages>(
                                    value: Languages.us,
                                    groupValue: _selectedLanguage,
                                    onChanged: (Languages? value) {
                                      if (value == Languages.us) {
                                        setState(
                                          () {
                                            _selectedLanguage = Languages.us;
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                                ListTile(
                                  title: Text(AppLocalizations.of(context)
                                      .translate('pt_BR')),
                                  leading: Radio<Languages>(
                                    value: Languages.pt,
                                    groupValue: _selectedLanguage,
                                    onChanged: (Languages? value) {
                                      if (value == Languages.pt) {
                                        setState(
                                          () {
                                            _selectedLanguage = Languages.pt;
                                          },
                                        );
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: Text(AppLocalizations.of(context)
                                  .translate('cancel'))),
                          ElevatedButton(
                              onPressed: () {
                                if (_selectedLanguage.toString() !=
                                    appLanguage.appLocal.toString()) {
                                  appLanguage.changeLanguage(
                                      Locale(_selectedLanguage.name));
                                  Navigator.pop(context, 'OK');
                                }
                              },
                              child: Text(AppLocalizations.of(context)
                                  .translate('ok'))),
                        ],
                      );
                    });
                  }),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(AppLocalizations.of(context).translate('about')),
              onTap: () => showAboutDialog(
                  context: context,
                  applicationVersion: '1.0.0',
                  children: [
                    Wrap(
                      children: [
                        Text(AppLocalizations.of(context)
                            .translate('createdBy')),
                        InkWell(
                          child: const Text('Torelli'),
                          onTap: () {
                            try {
                              launchUrlString('https://github.com/Torelli',
                                  mode: LaunchMode.externalApplication);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                          .translate('browserError'))));
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
                children: [
                  Text(AppLocalizations.of(context).translate('noWorkouts'))
                ],
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
        tooltip: AppLocalizations.of(context).translate('newWorkout'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> createWorkoutForm(BuildContext context) {
    return showDialog(
        barrierDismissible: index == 4 ? false : true,
        context: context,
        builder: (context) {
          var appLanguage = Provider.of<AppLanguage>(context);
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
                formStep = const WorkoutDaysForm();
                canContinue = days.isNotEmpty;
              case 1:
                formStep = const WorkoutGoalsForm();
                canContinue = goals.isNotEmpty;
              case 2:
                formStep = const WorkoutModalitiesForm();
                canContinue = modalities.isNotEmpty;
              case 3:
                formStep = const WorkoutDurationForm();
                canContinue = duration != '0h00m';
              case 4:
                formStep = const Center(child: CircularProgressIndicator());
              default:
                formStep = throw UnimplementedError();
            }
            return AlertDialog(
              title: index < 4
                  ? Text(AppLocalizations.of(context).translate('newWorkout'))
                  : const SizedBox.shrink(),
              insetPadding: const EdgeInsets.all(10),
              backgroundColor: index == 4
                  ? Colors.transparent
                  : Theme.of(context).dialogBackgroundColor,
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width - 100,
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
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
                        child: Text(
                            AppLocalizations.of(context).translate('back')))
                    : const SizedBox.shrink(),
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
                                      var newWorkout = await getResponse(
                                          appState.request,
                                          appLanguage.appLocal.toString());
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
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'genericError'))));
                                      }
                                    }
                                  }
                                : null,
                        child: Text(AppLocalizations.of(context)
                            .translate(index < 3 ? 'next' : 'generateWorkout')))
                    : const SizedBox.shrink(),
              ],
            );
          });
        });
  }
}
