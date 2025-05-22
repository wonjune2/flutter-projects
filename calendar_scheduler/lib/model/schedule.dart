import 'package:drift/drift.dart';

class Schedules extends TableManagerState {
  IntColumn get id => integer().autoIncrement()();
}
