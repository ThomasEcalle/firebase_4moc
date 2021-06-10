import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      home: FirebaseStorageHome(),
    ),
  );
}

class FirebaseStorageHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Go choper une photo"),
          onPressed: _pickImage,
        ),
      ),
    );
  }

  Future _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final UploadTask uploadTask = FirebaseStorage.instance.ref("images").putFile(file);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print("Task state: ${snapshot.state}");
        print("Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %");
      }, onError: (e) {
        print(uploadTask.snapshot);

        if (e.code == 'permission-denied') {
          print('User does not have permission to upload to this reference.');
        }
      });
    } else {
      print('No image selected.');
    }
  }
}
