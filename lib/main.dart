import 'dart:async';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:moc_4/analytics_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runZonedGuarded<Future<void>>(() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    runApp(MaterialApp(home: Home()));
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnalyticsManager(
      analytics: FirebaseAnalytics(),
      child: MaterialApp(
        home: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("coucou"),
            ElevatedButton(
              child: Text("CLICK Analytics"),
              onPressed: () {
                AnalyticsManager.of(context).logEvent(
                  name: "il_a_clique",
                  parameters: {
                    "toto": 42,
                  },
                );
              },
            ),
            ElevatedButton(
              child: Text("Click crash"),
              onPressed: _crash,
            ),
            ElevatedButton(
              child: Text("Add user"),
              onPressed: _addUser,
            ),
          ],
        ),
      ),
    );
  }

  void _crash() {
    throw Exception("Exception de test pour Firebase Crashlytics");
  }

  Future<void> _addUser() async {
    final CollectionReference ref = FirebaseFirestore.instance.collection('users/YFJujGZ5XGFXURSCk8hX/friends');

    try {
      await ref.add({"first_name": "John", "last_name": "Doe", "age": 42});
      print("Friend added");
    } catch (error) {
      print("Failed to add user: $error");
    }
  }
}
