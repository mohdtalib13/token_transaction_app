import 'package:firebase_auth/firebase_auth.dart';

enum UserRole {
  BRANCH,
  HEAD_OFFICE,
  TOKEN_GENERATOR,
}

class UserAccount {
  const UserAccount({
    required this.userId,
    required this.email,
    this.password,
    required this.role,
    this.isActive = true,
    this.uid,
  });

  final String userId;
  final String email;
  final String? password; // optional as we won't store this in Firestore
  final UserRole role;
  final bool isActive;
  final String? uid; // Firebase UID

// Convert Firestore Document to UserAccount
  factory UserAccount.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserAccount(
      userId: data['userId'],
      email: data['email'],
      role: UserRole.values.firstWhere(
          (role) => role.toString() == data['role'],
          orElse: () => UserRole.BRANCH),
      isActive: data['isActive'] ?? true,
      uid: uid,
    );
  }

  // Convert UserAccount to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'role': role.toString(),
      'isActive': isActive,
    };
  }
}
