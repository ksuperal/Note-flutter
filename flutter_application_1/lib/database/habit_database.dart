import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  //setup
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([HabitSchema], directory: dir.path);
  }

  //save first date of app startup
  Future<void> saveFirstLaunchDate() async {
    final exisitingSettings = await isar.appSettings.where().findFirst();
    if (exisitingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  //get first date of app startup
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  //List of habits
  final List<Habit> currentHabits = [];

  //create
  Future<void> addHabit(String habitName) async {
    //create a new habit
    final newHabit = Habit()..name = habitName;

    //write to the database
    await isar.writeTxn(() => isar.habits.put(newHabit));

    readHabits();
  }

  //read
  Future<void> readHabits() async {
    //fetch all habits
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    notifyListeners();
  }

  //Update check
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find habit by id
    final habit = await isar.habits.get(id);

    //update status
    if (habit != null) {
      await isar.writeTxn(() async {
        //if habit completed, add to list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();

          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        } else {
          //if habit not completed, remove from list
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        //save the updated habits back to the db
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }
  //update edit
  Future<void> updateHabitName(int id, String newName) async {
    //find habit by id
    final habit = await isar.habits.get(id);

    //update name
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }
  //delete
  Future<void> deleteHabit(int id) async {
    //delete habit by id
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    readHabits();
  }
}
