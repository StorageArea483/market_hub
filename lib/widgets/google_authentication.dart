import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_hub/pages/landing_page.dart';
import 'package:market_hub/providers/cart_ui_provider.dart';
import 'package:market_hub/services/auth_service.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/widgets/internet_connection.dart';

class GoogleAuthentication extends ConsumerWidget {
  const GoogleAuthentication({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    return ElevatedButton(
      onPressed: isLoading ? null : () => _handleGoogleSignIn(context, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo/google_logo.png', height: 24),
                const SizedBox(width: 12),
                const Text('Continue with Google'),
              ],
            ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    // Set loading to true
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();

      if (userCredential != null) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const InternetConnection(child: LandingPage()),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request not completed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Set loading to false
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}
