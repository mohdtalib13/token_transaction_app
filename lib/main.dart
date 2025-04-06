import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:token_transaction_app/firebase_options.dart';
import 'package:token_transaction_app/models/user_account.dart';
import 'package:token_transaction_app/pages/login_page.dart';
import 'package:token_transaction_app/pages/user_management.dart';
import 'package:token_transaction_app/pages/workflow_page.dart';
import 'package:token_transaction_app/services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const TokenTransactionApp(),
  );
}

class TokenTransactionApp extends StatelessWidget {
  const TokenTransactionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Token Transaction App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const UserManagementPage(),
      ),
    );
  }
}
