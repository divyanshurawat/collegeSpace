import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String name;
  final String email;
  final String photoUrl;
  final bool admin;
  final bool ban;

  User({this.name,this.admin,this.photoUrl,this.email,this.ban});

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      name: doc['displayName'],
      admin: doc['badge'],
      photoUrl: doc['photoUrl'],
      email:doc['email']
        ,ban: doc['ban']




    );
  }
}