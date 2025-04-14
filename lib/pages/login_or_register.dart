import 'package:flutter/material.dart';
import 'package:token_transaction_app/utils/my_textfield.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void togglePage() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showLogin ? 'Login' : 'Register'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextfield(
                controller: _emailController,
                autocorrect: false,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                labelText: 'Email',
                prefixIcon: const Icon(Icons.mail),
              ),
              const SizedBox(height: 12),
              MyTextfield(
                controller: _passwordController,
                autocorrect: false,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
              ),
              if (!showLogin) ...[
                const SizedBox(height: 12),
                MyTextfield(
                  controller: _confirmPasswordController,
                  autocorrect: false,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Add your login/register logic here
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(showLogin ? 'Login' : 'Register'),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(showLogin
                      ? "Don't have an account?"
                      : "Already have an account?"),
                  TextButton(
                    onPressed: togglePage,
                    child: Text(
                      showLogin ? "Register" : "Login",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
