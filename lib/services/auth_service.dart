import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// registration
Future<void> registerUser({
  required String email,
  required String password,
  required String username, 
}) async {
  
  try {
    
    // create user in firebase auth
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // save extra user data in firestore
    
    String uid = userCredential.user!.uid;

    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    // Create a new document for the user with their UID as the document ID
    await usersCollection.doc(uid).set({
      'username': username,
      'email': email,
      'created_at': FieldValue.serverTimestamp(), 
      // can add more fields here
    });
    
    print('Successfully registered user and saved data to Firestore!');

  } on FirebaseAuthException catch (e) {
    // Handle specific Firebase errors
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    } else {
      print('Error: ${e.message}');
    }
  } catch (e) {
    // Handle any other generic errors
    print('An error occurred: $e');
  }
}