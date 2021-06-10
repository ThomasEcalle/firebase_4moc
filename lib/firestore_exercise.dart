import 'dart:async';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:moc_4/analytics_manager.dart';
import 'package:moc_4/user.dart';
import 'package:moc_4/user_item.dart';

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
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('usersExercise').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              switch(snapshot.connectionState) {
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                case ConnectionState.active:
                  if (!snapshot.hasData) {
                    return Text("Aucun user");
                  }

                  final QuerySnapshot? querySnapshot = snapshot.data;
                  final List<QueryDocumentSnapshot>? queryDocumentsSnapshot = querySnapshot?.docs;

                  if (queryDocumentsSnapshot == null || queryDocumentsSnapshot.isEmpty) {
                    return Text("Aucun user");
                  }

                  return ListView.builder(
                    itemCount: queryDocumentsSnapshot.length,
                    itemBuilder: (BuildContext context, int index) {
                      final DocumentSnapshot documentSnapshot = queryDocumentsSnapshot[index];
                      if (documentSnapshot.exists) {
                        final User? user = User.fromJson(documentSnapshot.data() as Map<String, dynamic>?);
                        if (user == null) return SizedBox();
                        return UserItem(user: user);
                      }
                      return SizedBox();
                    },
                  );

                default:
                  return Text("Aucun user");
              }
            },
          ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addUser,
      ),
    );
  }

  Future<void> _addUser() async {
    final CollectionReference ref = FirebaseFirestore.instance
        .collection('usersExercise');

    try {
      await ref.add({"first_name": "John", "last_name": "Doe", "age": 42,});
      print("Friend added");
    } catch (error) {
      print("Failed to add user: $error");
    }
  }
}
