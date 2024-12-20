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
