import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ogs_service.dart';

class OgsLoginButton extends StatefulWidget {
  const OgsLoginButton({super.key});

  @override
  State<OgsLoginButton> createState() => _OgsLoginButtonState();
}

class _OgsLoginButtonState extends State<OgsLoginButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleLogin,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.login),
      label: Text(_isLoading ? 'Signing in...' : 'Sign in with OGS'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF9A825), // OGS-like orange/yellow
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final ogsService = Provider.of<OgsService>(context, listen: false);
      final success = await ogsService.login();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged in to OGS!')),
        );
        Navigator.of(context).pushReplacementNamed('/game_list');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to log in. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
