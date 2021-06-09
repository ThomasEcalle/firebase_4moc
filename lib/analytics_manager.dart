import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

class AnalyticsManager extends InheritedWidget {
  const AnalyticsManager({
    Key? key,
    required Widget child,
    required this.analytics,
  }) : super(key: key, child: child);
  final FirebaseAnalytics analytics;

  static AnalyticsManager of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: AnalyticsManager)!;
  }

  @override
  bool updateShouldNotify(AnalyticsManager e) => false;

  void logEvent({required String name, Map<String, dynamic>? parameters}) {
    analytics.logEvent(name: name, parameters: parameters);
  }
}