import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';

class Workout {
  final String name;
  final int estimatedDuration;
  final int sets;
  final int reps;
  final int effort;

  Workout({
    required this.name,
    required this.estimatedDuration,
    required this.sets,
    required this.reps,
    required this.effort,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      name: json['workout'],
      estimatedDuration: json['estimatedDuration'],
      sets: json['sets'],
      reps: json['reps'],
      effort: json['effort'],
    );
  }
}

class DailyPlan {
  final List<Workout> workouts;
  final int totalDuration;
  final String focusArea;
  final String difficulty;

  DailyPlan({
    required this.workouts,
    required this.totalDuration,
    required this.focusArea,
    required this.difficulty,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      workouts: (json['workouts'] as List)
          .map((workout) => Workout.fromJson(workout))
          .toList(),
      totalDuration: json['totalDuration'],
      focusArea: json['focusArea'],
      difficulty: json['difficulty'],
    );
  }
}

class Lift {
  final String name;
  final List<Map<String, dynamic>> sets;
  final double predicted1RM;

  Lift({required this.name, required this.sets, required this.predicted1RM});

  factory Lift.fromJson(Map<String, dynamic> json) {
    return Lift(
      name: json['name'],
      sets: List<Map<String, dynamic>>.from(json['sets']),
      predicted1RM: (json['predicted1RM'] as num).toDouble(),
    );
  }
}

class WorkoutData {
  final String date;
  final List<Lift> lifts;

  WorkoutData({required this.date, required this.lifts});

  factory WorkoutData.fromJson(Map<String, dynamic> json) {
    return WorkoutData(
      date: json['date'],
      lifts: (json['lifts'] as List).map((e) => Lift.fromJson(e)).toList(),
    );
  }
}

class TimeSeries {
  final List<WorkoutData> workoutData;

  TimeSeries({required this.workoutData});

  factory TimeSeries.fromJson(Map<String, dynamic> json) {
    return TimeSeries(
      workoutData: (json['workoutData'] as List)
          .map((e) => WorkoutData.fromJson(e))
          .toList(),
    );
  }
}

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  DailyPlan? _dailyPlan;
  TimeSeries? _timeSeries;
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadDailyPlan();
    _loadTimeSeriesData();
  }

  Future<void> _loadDailyPlan() async {
    final String jsonString =
        await rootBundle.loadString('lib/training/daily_plan.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _dailyPlan = DailyPlan.fromJson(jsonData);
    });
  }

  Future<void> _loadTimeSeriesData() async {
    final String jsonString =
        await rootBundle.loadString('lib/training/time_series.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _timeSeries = TimeSeries.fromJson(jsonData);
    });
  }

  Widget _buildTimeSeriesPlot(String liftName) {
  if (_timeSeries == null) {
    return const Center(child: CircularProgressIndicator());
  }

  final entries = _timeSeries!.workoutData.map((wd) {
    final lift = wd.lifts.firstWhere(
      (l) => l.name == liftName,
      orElse: () => Lift(name: liftName, sets: [], predicted1RM: 0),
    );
    return {'date': wd.date, 'predicted1RM': lift.predicted1RM};
  }).toList();

  final yValues = entries.map((e) => e['predicted1RM'] as double).toList();
  double rawMinY = yValues.reduce((a, b) => a < b ? a : b);
  double rawMaxY = yValues.reduce((a, b) => a > b ? a : b);

  // Round to nearest multiple of 10
  final minY = (rawMinY / 10).floor() * 10.0;
  final maxY = (rawMaxY / 10).ceil() * 10.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Main title
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Historical Predicted 1RM',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),

      // The chart itself
      Expanded(
        child: LineChart(
          LineChartData(
            clipData: FlClipData.all(),
            minY: minY * 0.95,
            maxY: maxY * 1.05,
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                axisNameWidget: const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    'Date',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                axisNameSize: 30,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 3,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= entries.length) return const SizedBox();
                    if (index == entries.length - 1) return const SizedBox();

                    final label = (entries[index]['date'] as String).substring(5);
                    return Transform.rotate(
                      angle: -0.5,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, right: 8),
                        child: Text(label, style: const TextStyle(fontSize: 10)),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: const Padding(
                  padding: EdgeInsets.only(top: 0, bottom: 2),
                  child: Text(
                    'Predicted 1RM (lbs)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                axisNameSize: 30,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (maxY - minY) / 2,
                  getTitlesWidget: (value, meta) {
                    // Skip min and max labels
                    if ((value - meta.min).abs() < 0.01 || (value - meta.max).abs() < 0.01) {
                      return const SizedBox.shrink();
                    }
                    final rounded = value.round();
                    return Text(
                      rounded.toString(),
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  entries.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    entries[index]['predicted1RM'] as double,
                  ),
                ),
                isCurved: false,
                color: Colors.blue,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3,        // smaller dot
                      color: Colors.blue,
                      strokeWidth: 0.5, // optional border
                      strokeColor: Colors.blue,
                    );
                  },           // smaller data points
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Training',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Heading and Focus Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Workout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_dailyPlan != null)
                  Text(
                    '${_dailyPlan!.focusArea} - ${_dailyPlan!.difficulty}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Total Duration
            if (_dailyPlan != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Total Duration: ${_dailyPlan!.totalDuration} minutes',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),

            // List of workouts
            Expanded(
              child: _dailyPlan == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _dailyPlan!.workouts.length,
                      itemBuilder: (context, index) {
                        final workout = _dailyPlan!.workouts[index];
                        final bool isExpanded = _expandedIndex == index;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                titleAlignment: ListTileTitleAlignment.center,
                                leading:
                                    const Icon(Icons.fitness_center, size: 32),
                                title: Text(workout.name),
                                subtitle: Text(
                                  '${workout.sets} sets × ${workout.reps} reps\n'
                                  'Duration: ${workout.estimatedDuration} mins • Effort: ${workout.effort}%',
                                ),
                                trailing: IconButton(
                                  icon: Transform.rotate(
                                    angle: isExpanded ? 3.14 / 2 : 0,
                                    child: const Icon(Icons.chevron_right),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _expandedIndex = isExpanded ? -1 : index;
                                    });
                                  },
                                ),
                                isThreeLine: true,
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded ? -1 : index;
                                  });
                                },
                              ),

                              // Animated chart
                              AnimatedSize(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOut,
                                child: SizedBox(
                                  height: isExpanded ? 350 : 0,
                                  child: isExpanded
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: _buildTimeSeriesPlot(
                                                  workout.name),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
