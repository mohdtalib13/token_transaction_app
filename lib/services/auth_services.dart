import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:token_transaction_app/models/user_account.dart';

/*
class AuthService {
  // Singleton Pattern
  AuthService._privateConstructor();

  static final AuthService _instance = AuthService._privateConstructor();

  static AuthService get instance => _instance;

  // In-memory storage of user accounts
  final List<UserAccount> _accounts = [
    // Default Token Generator account
    const UserAccount(
      userId: 'token_admin',
      password: 'admin',
      role: UserRole.TOKEN_GENERATOR,
    ),
  ];

  // current logged in user
  UserAccount? currentUser;

  // check if any user is logged in
  bool get isLoggedIn => currentUser != null;

  // check if logged in user is Token Generator
  bool get isTokenGenerator => currentUser?.role == UserRole.TOKEN_GENERATOR;

  // Login with Credentials
  bool login(String userId, String password) {
    for (var account in _accounts) {
      if (account.userId == userId &&
          account.password == password &&
          account.isActive) {
        return true;
      }
    }
    return false;
  }

  // logout current user
  void logout() {
    currentUser = null;
  }

  // create new user account(Token Generator only)
  bool createAccount(String userId, String password, UserRole role) {
    // check if user already exists
    if (_accounts.any((account) => account.userId == userId)) {
      return false;
    }
    // create new account
    _accounts.add(
      UserAccount(
        userId: userId,
        password: password,
        role: role,
      ),
    );
    return true;
  }

  //  get all accounts (for Token Generator to manage)
  List<UserAccount> getAllAccounts() {
    return List.from(_accounts);
  }

  // Deactivate account
  bool deactivateAccount(String userId) {
    int index = _accounts.indexWhere((account) => account.userId == userId);
    if (index != -1) {
      _accounts[index] = UserAccount(userId: _accounts[index].userId,
        password: _accounts[index].password,
        role: _accounts[index].role,
        isActive: false,
      );
      return true;
  }
    return false;
  }
}
*/

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user data
  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if any user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Check if logged in user is Token generator
  bool get isTokenGenerator => _currentUser?.role == UserRole.TOKEN_GENERATOR;

  // Constructor initializes the listener
  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);

    // Check if we need to initialize the admin account
    _initializeAdminAccount();
  }

  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser == null;
      notifyListeners();
      return;
    }

    // try to get the user from Firestore
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(
          firebaseUser.uid).get();

      if (userDoc.exists) {
        _currentUser = UserAccount.fromFirestore(
            userDoc.data() as Map<String, dynamic>, firebaseUser.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching user data: $e');
      _currentUser = null;
      notifyListeners();
    }
  }

  // Create default admin account if it doesn't exist
  Future<void> _initializeAdminAccount() async {
    try {
      // Check if admin account exists in users collection
      QuerySnapshot adminQuery = await _firestore
          .collection('users')
          .where('userId', isEqualTo: 'token_admin')
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        // Create admin account in Firebase Auth
        UserCredential adminCredential = await _auth
            .createUserWithEmailAndPassword(
          email: 'admin@tokentransaction.com',
          password: 'admin123',
        );

        // Create admin user in Firestore
        UserAccount adminAccount = UserAccount(
          userId: 'token_admin',
          email: 'admin@tokentransaction.com',
          role: UserRole.TOKEN_GENERATOR,
          uid: adminCredential.user!.uid,
        );

        await _firestore
            .collection('users')
            .doc(adminCredential.user!.uid)
            .set(adminAccount.toFirestore());
      }
    } catch (e) {
      print('Error initializing admin account: $e');
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password,);

      // Check if user document exist
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(
          result.user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Check if account is active
        if (userData['isActive'] == false) {
          await _auth.signOut();
          return false;
        }

        _currentUser = UserAccount.fromFirestore(userData, result.user!.uid);
        notifyListeners();
        return true;
      }

      // User not found in Firestore, sign out
      await _auth.signOut();
      return false;
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  // Logout current user
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
  // Create new user account (Token Generator only)
  Future<bool> createAccount(String userId, String email, String password, UserRole role) async {
    try {
      // Check if userId already exists
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return false;
      }

      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user in Firestore
      UserAccount newAccount = UserAccount(
        userId: userId,
        email: email,
        role: role,
        uid: result.user!.uid,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newAccount.toFirestore());

      return true;
    } catch (e) {
      print('Error creating account: $e');
      return false;
    }
  }

  // Get all accounts (for Token Generator to manage)
  Future<List<UserAccount>> getAllAccounts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .get();

      List<UserAccount> accounts = querySnapshot.docs.map((doc) {
        return UserAccount.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return accounts;
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  // Deactivate account
  Future<bool> deactivateAccount(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'isActive': false});
      return true;
    } catch (e) {
      print('Error deactivating account: $e');
      return false;
    }
  }

  // Reactivate account
  Future<bool> activateAccount(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'isActive': true});
      return true;
    } catch (e) {
      print('Error activating account: $e');
      return false;
    }
    }
  }
