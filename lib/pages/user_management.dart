import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:token_transaction_app/models/user_account.dart';
import 'package:token_transaction_app/pages/login_or_register.dart';
import 'package:token_transaction_app/pages/login_page.dart';
import 'package:token_transaction_app/pages/workflow_page.dart';
import 'package:token_transaction_app/services/auth_services.dart';
import 'package:token_transaction_app/widgets/role.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({
    super.key,
    required void Function() onTap,
  });

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _userIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.BRANCH;
  bool _isLoading = false;
  List<UserAccount> _accounts = [];
  void Function()? onTap;

  @override
  void initState() {
    super.initState();
    _loadAccounts;
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final accounts = await authService.getAllAccounts();

      setState(() {
        _accounts = accounts;
      });
    } catch (e) {
      _showMessage('Error loading accounts: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void createNewAccount() async {
    if (_userIdController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.createAccount(
        _userIdController.text,
        _emailController.text,
        _passwordController.text,
        _selectedRole,
      );

      if (success) {
        _showMessage('Account Created Successfully');
        _userIdController.clear();
        _emailController.clear();
        _passwordController.clear();
        _loadAccounts(); // Refresh the list
      } else {
        _showMessage('User Id already exists');
      }
    } catch (e) {
      _showMessage('Error Creating Account: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleAccountStatus(UserAccount account) async {
    if (account.uid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success;

      if (account.isActive) {
        success = await authService.deactivateAccount(account.uid!);
      } else {
        success = await authService.activateAccount(account.uid!);
      }

      if (success) {
        _showMessage('Account status updated');
        _loadAccounts(); // Refresh the list
      } else {
        _showMessage('Failed to update account status');
      }
    } catch (e) {
      _showMessage('Error updating account: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management Page'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkflowPage(),
                ),
              );
            },
            tooltip: 'Go to Workflow',
            icon: const Icon(Icons.work),
          ),
          IconButton(
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginOrRegisterPage(),
                ),
              );
            },
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout_outlined,
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildBody(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Create new account card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Create new account'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: 'User Id',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.BRANCH,
                        child: Text('Branch'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.HEAD_OFFICE,
                        child: Text('Head Office'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.TOKEN_GENERATOR,
                        child: Text('Token Generator'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: createNewAccount,
                    child: const Text('Create New Account'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onTap,
                        child: const Text(
                          'LogIn',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Existing Accounts'),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _loadAccounts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildAccountsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList() {
    if (_accounts.isEmpty) {
      return const Center(
        child: Text('No account found'),
      );
    }

    return ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Icon(
                _getIconForRole(account.role),
              ),
              title: Text(account.userId),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRoleName(account.role),
                  ),
                  Text(
                    account.email,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: SizedBox(
                width: 160,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Switch(
                      value: account.isActive,
                      onChanged: (value) => _toggleAccountStatus(account),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded),
                      onPressed: () {
                        _showCredentialDialog(account);
                      },
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.TOKEN_GENERATOR:
        return Icons.admin_panel_settings;
      case UserRole.HEAD_OFFICE:
        return Icons.business;
      case UserRole.BRANCH:
        return Icons.store;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.TOKEN_GENERATOR:
        return 'Token Generator';
      case UserRole.HEAD_OFFICE:
        return 'Head Office';
      case UserRole.BRANCH:
        return 'Branch';
    }
  }

  void _showCredentialDialog(UserAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User Id: ${account.userId}'),
            Text('Password: ${account.password}'),
            Text('Role: ${_getRoleName(account.role)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
