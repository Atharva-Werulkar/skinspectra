import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skinspectra/model/model.dart';

//const docRef = db.collection('users').doc('user_id');

class DatabaseServices {
  static Future<void> addUserToDatabase({
    required String? id,
    required String? image,
    required String? about,
    required String? name,
    required String? email,
    required String? dob,
    required String? mobile,
  }) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');
      await users.doc(id).set({
        'id': id,
        'image': image,
        'about': about,
        'name': name,
        'email': email,
        'dob': dob,
        'mobile': mobile,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<MyUser> getUser(String id) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');
      final snapshot = await users.doc(id).get();
      final data = snapshot.data() as Map<String, dynamic>;

      return MyUser.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Stream<MyUser> getCurrentUser() async* {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      print(user?.uid);

      Stream<DocumentSnapshot<Map<String, dynamic>>> snapshot =
          FirebaseFirestore.instance
              .collection('Users')
              .doc(user?.uid)
              .snapshots();

      print(snapshot);

      yield* snapshot.map((event) => MyUser.fromJson(event.data()));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> updateProfilePicture(File file, String? userId) async {
    final ext = file.path.split('.').last;
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('profile_pictures/$userId.$ext');

    try {
      await storageReference.putFile(file);
      final url = await storageReference.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'image': url});
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateProfile({
    required String? userId,
    required String? name,
    required String? about,
    required String? mobile,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'name': name, 'about': about, 'mobile': mobile});
    } catch (e) {
      rethrow;
    }
  }
}
