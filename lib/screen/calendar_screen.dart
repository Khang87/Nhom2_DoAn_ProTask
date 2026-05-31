import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';
import '../provider/locale_provider.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(() => context.read<TaskProvider>().fetchAllTasks());
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(localeProvider.getText('calendar_title'))),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final tasks = context.read<TaskProvider>().tasks;
              return tasks.where((task) => isSameDay(task.deadline, day)).toList();
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final selectedTasks = taskProvider.tasks
                    .where((task) => isSameDay(task.deadline, _selectedDay))
                    .toList();

                if (selectedTasks.isEmpty) {
                  return Center(child: Text(localeProvider.getText('no_tasks_day')));
                }

                return ListView.builder(
                  itemCount: selectedTasks.length,
                  itemBuilder: (context, index) {
                    final task = selectedTasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(DateFormat('HH:mm').format(task.deadline)),
                      trailing: Icon(
                        task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: task.isDone ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
