import 'dart:convert';
import 'package:ai_personal_trainer/model/workout_request.dart';
import 'package:ai_personal_trainer/model/workout.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dotenv/dotenv.dart';

Future<Workout> getResponse(WorkoutRequest request) async {
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

  print(response.choices.first.message.content![0].text);

  final Map<String, dynamic> parsed =
      jsonDecode(response.choices.first.message.content![0].text.toString());

  var newWorkout = Workout.fromJson(parsed, request.goals, request.modalities);
  return newWorkout;
}
