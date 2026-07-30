import 'package:dairycare_mobile/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('schema 3 upgrades add Phase 2C projections and history caches', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute(
          'CREATE TABLE local_animals (id TEXT NOT NULL PRIMARY KEY)',
        );
        database.execute('PRAGMA user_version = 3');
      },
    );
    final database = AppDatabase(executor);
    addTearDown(database.close);

    final animalColumns = await database
        .customSelect('PRAGMA table_info(local_animals)')
        .get();
    final columnNames = animalColumns
        .map((row) => row.read<String>('name'))
        .toSet();
    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name IN ('local_animal_weights', 'local_animal_status_changes')",
        )
        .get();

    expect(columnNames, contains('latest_weight_id'));
    expect(columnNames, contains('latest_weight_kg'));
    expect(columnNames, contains('latest_weight_observed_at'));
    expect(tables.map((row) => row.read<String>('name')).toSet(), {
      'local_animal_weights',
      'local_animal_status_changes',
    });
  });

  test('schema 4 upgrade creates the offline milk-entry cache', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute('PRAGMA user_version = 4');
      },
    );
    final database = AppDatabase(executor);
    addTearDown(database.close);

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'local_milk_entries'",
        )
        .get();

    expect(tables.single.read<String>('name'), 'local_milk_entries');
  });
}
