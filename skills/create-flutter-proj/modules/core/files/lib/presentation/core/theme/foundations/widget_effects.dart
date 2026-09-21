import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

/// Spacing scale — the only numbers allowed in padding/gaps. `s4` = 16px.
class AppSpacings {
  AppSpacings._();
  static const double s0 = 0;
  static const double s0_5 = 2;
  static const double s1 = 4;
  static const double s1_5 = 6;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

class AppRadii {
  AppRadii._();
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double full = 9999;
}

class AppDurations {
  AppDurations._();
  static const Duration shorter = Duration(milliseconds: 100);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration long = Duration(milliseconds: 600);
}

class AppShadows {
  AppShadows._();
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.1),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.1),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.08),
      offset: Offset(0, 12),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];
}
