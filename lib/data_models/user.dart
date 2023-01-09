class CustomUser {
  final String uid;
  final String? displayName;
  final String? email;
  final bool emailVerified;
  final bool isAnonymous;
  final DateTime? createdOn;
  final DateTime? lastSignTime;
  // final String? photoUrl;

  CustomUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.isAnonymous,
    required this.emailVerified,
    required this.createdOn,
    required this.lastSignTime,
  });
}

// UserCredential(
//   additionalUserInfo: AdditionalUserInfo(
//     isNewUser: true, 
//     profile: {}, 
//     providerId: null, 
//     username: null), 
//   credential: null, 
//   user: User(
//     displayName: null, 
//     email: null, 
//     emailVerified: false, 
//     isAnonymous: true, 
//     metadata: UserMetadata(
//       creationTime: 2022-08-08 10:08:40.081, 
//       lastSignInTime: 2022-08-08 10:08:40.081), 
//   phoneNumber: null, 
//   photoURL: null, 
//   providerData, 
//   [], 
//   refreshToken: , 
//   tenantId: null, 
//   uid: AIFYj53FH3RvucMZUOzFDIHEyVt1
//   )
// )