import 'package:hive_ce/hive_ce.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/model/greeting/greeting_cache/greeting_cache.dart';

part 'hive_adapters.g.dart';

/// The single registry: adapters, type ids and `Hive.registerAdapters()`
/// (in `hive_registrar.g.dart`) are generated from this list. Append new
/// `*Cache` types at the end — reordering changes type ids and breaks
/// existing boxes on users' devices.
@GenerateAdapters([AdapterSpec<GreetingCache>()])
// ignore: unused_element
void _hiveAdapters() {}
