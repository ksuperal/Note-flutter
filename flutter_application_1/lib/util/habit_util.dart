//given habit list of completion days
//is the habit completed today?
import 'package:flutter_application_1/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day);
}

//prepare heat map dataset
Map<DateTime, int>prepHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> datasets = {};

  //loop through habits
  for (var habit in habits){
    for (var date in habit.completedDays){
      //normalize date to avoid time mismatch
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      //if the date already exists, increment the count
      if (datasets.containsKey(normalizedDate)){
        datasets[normalizedDate] = datasets[normalizedDate]! + 1;
      } else {
        //if the date does not exist, add it
        datasets[normalizedDate] = 1;
    }
  }
}
  return datasets;
}