/// User profile stored in Firestore, linked to Firebase Auth UID.
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
    );
  }
}
