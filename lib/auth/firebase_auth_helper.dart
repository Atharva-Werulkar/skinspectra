import 'package:firebase_auth/firebase_auth.dart';
import 'package:skinspectra/auth/database_services.dart';

class FirebaseAuthHelper {
  //sign up using email and password
  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
    required String dob,
    required String mobile,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      DatabaseServices.addUserToDatabase(
        id: userCredential.user!.uid,
        image: '',
        about: '',
        name: name,
        email: email,
        dob: dob,
        mobile: mobile,
      );

      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
    return user;
  }

  //sign in using email and password
  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }

    return user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
