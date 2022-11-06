import 'package:flutter/material.dart';

abstract class DeviceSize {
  static const int LARGE = 4;
  static const int MEDIUM = 3;
  static const int MEDIUM_SMALL = 2;
  static const int SMALL = 1;

  static const double MEDIUM_SMALL_BREAKPOINT = 500;
  static const double MEDIUM_BREAKPOINT = 1000;
  static const double LARGE_BREAKPOINT = 1500;

  static int get_breakpoint(double width) {
    if (width < MEDIUM_SMALL_BREAKPOINT) return SMALL;
    if (width < MEDIUM_BREAKPOINT) return MEDIUM_SMALL;
    if (width < LARGE_BREAKPOINT) return MEDIUM;
    return LARGE;
  }
}

abstract class DeviceHeight {
  static const int LARGE = 4;
  static const int MEDIUM = 3;
  static const int MEDIUM_SMALL = 2;
  static const int SMALL = 1;

  static const double MEDIUM_BREAKPOINT = 700;
  static const double LARGE_BREAKPOINT = 900;

  static int get_breakpoint(double height) {
    if (height < MEDIUM_BREAKPOINT) return SMALL;
    if (height < LARGE_BREAKPOINT) return MEDIUM;
    return LARGE;
  }
}

int get_device_size(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  return DeviceSize.get_breakpoint(width);
}

int get_device_height(BuildContext context) {
  double height = MediaQuery.of(context).size.height;
  return DeviceHeight.get_breakpoint(height);
}
