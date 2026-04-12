import 'package:flutter/material.dart';

class DashboardScope extends InheritedWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSwitch;

  const DashboardScope({
    super.key,
    required this.currentIndex,
    required this.onTabSwitch,
    required super.child,
  });

  static DashboardScope of(BuildContext context) {
    final DashboardScope? result = context.dependOnInheritedWidgetOfExactType<DashboardScope>();
    assert(result != null, 'No DashboardScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(DashboardScope oldWidget) {
    return currentIndex != oldWidget.currentIndex;
  }
}
