import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'AI PersonalTrainer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class WorkoutRequest {
  List<String> days;
  List<String> goals;
  List<String> modalities;
  String duration;

  WorkoutRequest(this.days, this.goals, this.modalities, this.duration);

  Map toJson() => {
        'days': days,
        'modalities': modalities,
        'goals': goals,
        'duration': duration
      };
}

class Exercise {
  String name;
  String description;
  String reps;

  Exercise(this.name, this.description, this.reps);
}

class WorkoutDay {
  String day;
  String name;
  String duration;
  List<Exercise> exercises;

  WorkoutDay(this.day, this.name, this.duration, this.exercises);
}

class Workout {
  String name;
  String goals;
  List<WorkoutDay> days;

  Workout(this.name, this.goals, this.days);
}

class MyAppState extends ChangeNotifier {
  WorkoutRequest request = WorkoutRequest([], [], [], '0h00m');
  List<Workout> workouts = [];

  void updateRequest(WorkoutRequest newReq) {
    request = newReq;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<String> getResponse(WorkoutRequest request) async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  OpenAI.apiKey = env['API_KEY']!;
  OpenAI.baseUrl = env['API_URL']!;

  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            env['SYS_PROMPT']!)
      ]);

  final userMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            jsonEncode(request))
      ]);

  final requestMessages = [systemMessage, userMessage];

  OpenAIChatCompletionModel response = await OpenAI.instance.chat.create(
    model: "gpt-3.5-turbo",
    responseFormat: {'type': 'json_object'},
    seed: 6,
    messages: requestMessages,
    temperature: 0.2,
  );

  print(response.choices.first.message);
  return response.choices.first.message.toString();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('AI Personal Trainer'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
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
                  title: Text('New Workout'),
                  insetPadding: EdgeInsets.all(10),
                  content: Container(
                    width: MediaQuery.of(context).size.width - 100,
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: formStep,
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
                                        await getResponse(appState.request);
                                        if (context.mounted) {
                                          setState(() {
                                            index = 0;
                                            appState.updateRequest(
                                                WorkoutRequest(
                                                    [], [], [], "0h00m"));
                                          });
                                          Navigator.pop(context, 'Success');
                                        }
                                      }
                                    : null,
                            child:
                                Text(index < 3 ? 'Next' : 'Generate workout'))
                        : SizedBox.shrink(),
                  ],
                );
              });
            }),
        tooltip: 'New Workout',
        child: const Icon(Icons.add),
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
      newReq.duration = '$hours\h$minutes\m';
      appState.updateRequest(newReq);
    }

    return Column(
      children: [
        Text('Select the maximum duration of the workout'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
