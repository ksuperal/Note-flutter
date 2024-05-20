import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/components/my_habit_tile.dart';
import 'package:flutter_application_1/components/my_heat_map.dart';
import 'package:flutter_application_1/database/habit_database.dart';
import 'package:flutter_application_1/database/habit_database.dart';
import 'package:flutter_application_1/models/habit.dart';
import 'package:flutter_application_1/theme/theme_provider.dart';
import 'package:flutter_application_1/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  final TextEditingController textController = TextEditingController();
  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Enter habit name',
                ),
              ),
              actions: [
                //save button
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;
                    context.read<HabitDatabase>().addHabit(newHabitName);
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text('Save'),
                ),
                //cancel button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit box
  void editHabitBox(Habit habit) {
    textController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(controller: textController),
              actions: [
                //save button
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, newHabitName);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
                //cancel button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  //delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Are you sure you want to delete this habit?'),
              actions: [
                //delete button
                MaterialButton(
                  onPressed: () {
                    context.read<HabitDatabase>().deleteHabit(habit.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                //cancel button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(
          Icons.add,
        ),
      ),
      body: ListView(children: [_buildHeatMap(), _buildHabitList()]),
    );
  }

  //build heat map
  Widget _buildHeatMap() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();
    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return heatmap UI
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        //once the data is avaliable -> build heatmap
        if (snapshot.hasData) {
          return MyHeatMap(startDate: snapshot.data!, datasets: prepHeatMapDataset(currentHabits));
        } else {
          return Container();
        }
      },
    );
  }

  //build habit list
  Widget _buildHabitList() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();
    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return list of habits UI
    return ListView.builder(
        itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final habit = currentHabits[index];
          bool isCompleteToday = isHabitCompletedToday(habit.completedDays);

          return MyHabitTile(
              text: habit.name,
              isCompleted: isCompleteToday,
              onChanged: (value) => checkHabitOnOff(value, habit),
              editHabit: (context) => editHabitBox(habit),
              deleteHabit: (context) => deleteHabitBox(habit));
        });
    //4.31.57
  }
}
