import 'package:flutter/material.dart';
import 'package:token_transaction_app/models/user_account.dart';
import 'package:token_transaction_app/pages/login_or_register.dart';
import 'package:token_transaction_app/services/auth_services.dart';

class WorkflowPage extends StatefulWidget {
  const WorkflowPage({
    super.key,
    this.role,
  });

  final UserRole? role;

  @override
  State<WorkflowPage> createState() => _WorkflowPageState();
}

class _WorkflowPageState extends State<WorkflowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitleForRole(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginOrRegisterPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildWorkflowForRole(),
    );
  }

  String _getTitleForRole() {
    switch (widget.role) {
      case UserRole.TOKEN_GENERATOR:
        return 'Token Generator Workflow';
      case UserRole.HEAD_OFFICE:
        return 'Head Office Workflow';
      case UserRole.BRANCH:
        return 'Branch Workflow';
      case null:
        return 'No User found';
    }
  }

  Widget _buildWorkflowForRole() {
    // Placeholder for different workflows based on role
    switch (widget.role) {
      case UserRole.TOKEN_GENERATOR:
        return _buildTokenGeneratorWorkflow();
      case UserRole.HEAD_OFFICE:
        return _buildHeadOfficeWorkflow();
      case UserRole.BRANCH:
        return _buildBranchWorkflow();
      case null:
        return _buildEmptyPage();
    }
  }

  Widget _buildTokenGeneratorWorkflow() {
    return const Column(
      children: [
        Icon(Icons.admin_panel_settings_outlined),
        SizedBox(height: 16),
        Text('Token Generator Workflow'),
        SizedBox(height: 24),
        Text(
            'This section would contains token generation and management features.'),
      ],
    );
  }

  Widget _buildHeadOfficeWorkflow() {
    return const Column(
      children: [
        Icon(Icons.business),
        SizedBox(height: 16),
        Text('Head Office Workflow'),
        SizedBox(height: 24),
        Text('This section would contain head office and management features.'),
      ],
    );
  }

  Widget _buildBranchWorkflow() {
    return const Column(
      children: [
        Icon(Icons.store),
        SizedBox(height: 16),
        Text('Branch Workflow'),
        SizedBox(height: 24),
        Text('This would contain branch and management features'),
      ],
    );
  }

  Widget _buildEmptyPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No User Found',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
