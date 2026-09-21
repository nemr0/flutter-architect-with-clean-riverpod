import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as s;

enum Flavor { dev, staging, prod }

/// Per-flavor config. Values come from `--dart-define-from-file=.env.<flavor>`
/// (see Makefile) — never literals. Add a key: put it in every `.env.*` and
/// `.env.example`, then read it here with `String.fromEnvironment`.
class Environment {
  const Environment._(this.flavor);

  /// Native flavor (`flutter run --flavor`) wins; else `--dart-define=FLAVOR`;
  /// else prod — so a unit test with no flavor behaves like production.
  static final Environment instance = Environment._(
    Flavor.values.firstWhere(
      (f) => f.name == (s.appFlavor ?? const String.fromEnvironment('FLAVOR')),
      orElse: () => Flavor.prod,
    ),
  );

  final Flavor flavor;

  String get name => flavor.name;
  bool get isProd => flavor == Flavor.prod;

  String get title => switch (flavor) {
    Flavor.prod => '__APP_TITLE__',
    Flavor.staging => '__APP_TITLE__ Staging',
    Flavor.dev => '__APP_TITLE__ Dev',
  };

  /// Debug tooling (inspector, verbose logs) is on everywhere except a
  /// release prod build.
  static bool get loggingEnabled => !instance.isProd || kDebugMode;
}
