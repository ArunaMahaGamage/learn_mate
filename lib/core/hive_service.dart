import 'package:hive_flutter/hive_flutter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.openBox('offline_cache'); // simple cache box
  await Hive.openBox('planner_box'); // store planner items offline
  await Hive.openBox('resources_box'); // store resources list offline
  await Hive.openBox('quiz_box'); // store quiz list offline
}
