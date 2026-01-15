import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_hub/pages/google_signup.dart';
import 'package:market_hub/pages/landing_page.dart';
import 'package:market_hub/styles/style.dart';
import 'package:market_hub/widgets/internet_connection.dart';

class CheckConnection extends StatelessWidget {
  const CheckConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }
        if (snapshot.hasData) {
          return const InternetConnection(child: LandingPage());
        } else {
          return const InternetConnection(child: GoogleSignup());
        }
      },
    );
  }
}
