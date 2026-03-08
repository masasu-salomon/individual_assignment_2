import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Verify email', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 80, color: AppConstants.primaryDark),
              const SizedBox(height: 24),
              Text(
                'Check your email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppConstants.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to ${auth.user?.email ?? 'the email you signed up with'}. Please open it to verify your account.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              if (auth.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        await auth.checkEmailVerified();
                        if (context.mounted && auth.isAuthenticated) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('I\'ve verified my email'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        auth.clearError();
                        await auth.resendVerificationEmail();
                      },
                child: const Text('Resend verification email'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
