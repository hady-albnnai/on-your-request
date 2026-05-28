import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String    uid;
  final String    phoneNumber;
  final String    userType;
  final Timestamp createdAt;
  final Timestamp lastLoginAt;

  const UserModel({
    required this.uid,
    required this.phoneNumber,
    this.userType   = 'user',
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid:         doc.id,
      phoneNumber: d['phoneNumber']  ?? '',
      userType:    d['userType']     ?? 'user',
      createdAt:   d['createdAt']    ?? Timestamp.now(),
      lastLoginAt: d['lastLoginAt']  ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'phoneNumber':  phoneNumber,
    'userType':     userType,
    'createdAt':    createdAt,
    'lastLoginAt':  lastLoginAt,
  };
}
