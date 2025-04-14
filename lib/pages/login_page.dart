import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:token_transaction_app/models/user_account.dart';
import 'package:token_transaction_app/pages/user_management.dart';
import 'package:token_transaction_app/pages/workflow_page.dart';
import 'package:token_transaction_app/services/auth_services.dart';
import 'package:token_transaction_app/utils/my_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    // required this.onTap,
  });

  // final void Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // late final void Function()? onTap;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        // Navigate to appropriate page based on role
        final currentUser = authService.currentUser!;

        if (currentUser.role == UserRole.TOKEN_GENERATOR) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserManagementPage(onTap: () {},),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkflowPage(),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid credential or inactive account';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error signing in: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN'),
        centerTitle: true,
      ),
      body: Card(
        elevation: 4,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Login'),
              const SizedBox(height: 24),
              MyTextfield(
                controller: _emailController,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                labelText: 'Enter Email',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              MyTextfield(
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                labelText: 'Enter Password',
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _attemptLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: (){},
                    child: const Text(
                      "SignUp",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
