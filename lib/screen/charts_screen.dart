import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';
import '../provider/locale_provider.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(localeProvider.getText('charts_title'))),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;
          if (tasks.isEmpty) {
            return Center(child: Text(localeProvider.getText('no_chart_data')));
          }

          int done = tasks.where((t) => t.isDone).length;
          int todo = tasks.length - done;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(localeProvider.getText('task_completion_rate'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 50),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: done.toDouble(),
                          title: '${((done/tasks.length)*100).toStringAsFixed(1)}%',
                          color: Colors.green,
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          value: todo.toDouble(),
                          title: '${((todo/tasks.length)*100).toStringAsFixed(1)}%',
                          color: Colors.blue,
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(localeProvider.getText('completed'), Colors.green),
                    _buildLegendItem(localeProvider.getText('incomplete'), Colors.blue),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Done", done, Colors.green),
                    _buildStatItem("Todo", todo, Colors.blue),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
