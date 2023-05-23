import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userID;
  final String firstName;
  final String email;
  final String profilePictureURL;
  final String phoneNumber;
  final String password;

  User({
    this.userID,
    this.firstName,
    this.email,
    this.profilePictureURL,
    this.phoneNumber,
    this.password
  });

  Map<String, Object> toJson() {
    return {
      'userID': userID,
      'firstName': firstName,
      'email':email,
      'profilePictureURL': profilePictureURL==null?'':profilePictureURL,

      'phoneNumber':phoneNumber==null?'':phoneNumber,
      'password':password
    };
  }

  factory User.fromJson(Map<String, Object> doc) {
    User user = new User(
      userID: doc['userID'],
      firstName: doc['firstName'],
      email: doc['email'],
      profilePictureURL: doc['profilePictureURL'],
      phoneNumber: doc['phoneNumber'],
      password: doc['password']
    );
    return user;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }

}
