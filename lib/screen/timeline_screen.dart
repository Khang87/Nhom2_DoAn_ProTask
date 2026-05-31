import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';
import '../provider/locale_provider.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TaskProvider>().fetchAllTasks());
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(localeProvider.getText('timeline_title'))),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = taskProvider.tasks;
          if (tasks.isEmpty) {
            return Center(child: Text(localeProvider.getText('no_tasks')));
          }
          // Sao chép danh sách để sắp xếp
          final sortedTasks = List.from(tasks);
          sortedTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

          return ListView.builder(
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              final task = sortedTasks[index];
              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1,
                isFirst: index == 0,
                isLast: index == sortedTasks.length - 1,
                indicatorStyle: IndicatorStyle(
                  width: 20,
                  color: task.isDone ? Colors.green : Colors.blue,
                  padding: const EdgeInsets.all(6),
                ),
                endChild: Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(task.deadline),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(task.description, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
