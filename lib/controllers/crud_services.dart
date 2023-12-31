import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
class CRUDService {
  User? user = FirebaseAuth.instance.currentUser;

  // Add new contacts to firestore
  Future addNewContacts(String name, String phone, String email, String imageUrl) async {
    Map<String, dynamic> data = {"name": name, "email": email, "phone": phone, "imageUrl": imageUrl};
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("contacts")
          .add(data);
      print("Document Added");
    } catch (e) {
      print(e.toString());
    }
  }

  // Read documents inside firestore
  Stream<QuerySnapshot> getContacts({String? searchQuery}) async* {
    var contactsQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("contacts")
        .orderBy("name");

    // A filter to perform search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      String searchEnd = "$searchQuery\uf8ff";
      contactsQuery = contactsQuery.where("name",
          isGreaterThanOrEqualTo: searchQuery, isLessThan: searchEnd);
    }

    var contacts = contactsQuery.snapshots();
    yield* contacts;
  }

  // Upload image URL to Firestore
  Future<String> uploadImage(String imagePath) async {
    try {
      // Upload image to Firestore and get the URL
      String imageUrl = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("images")
          .add({"timestamp": FieldValue.serverTimestamp()}).then((docRef) async {
        String fileName = docRef.id;
        Reference storageReference =
        FirebaseStorage.instance.ref().child('images/$fileName');
        await storageReference.putFile(File(imagePath));
        return storageReference.getDownloadURL();
      });

      return imageUrl;
    } catch (e) {
      print(e.toString());
      return ''; // You might want to handle this error more gracefully
    }
  }

  // Update a contact
  Future updateContact(String name, String phone, String email, String docID, {String? imageUrl}) async {
    Map<String, dynamic> data = {"name": name, "email": email, "phone": phone, "imageUrl": imageUrl};
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("contacts")
          .doc(docID)
          .update(data);
      print("Document Updated");
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete contact from firestore
  Future deleteContact(String docID) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("contacts")
          .doc(docID)
          .delete();
      print("Contact Deleted");
    } catch (e) {
      print(e.toString());
    }
  }
}
