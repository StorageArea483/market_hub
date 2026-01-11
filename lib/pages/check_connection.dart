import 'package:flutter/material.dart';
import 'package:market_hub/pages/google_signup.dart';
import 'package:market_hub/widgets/internet_connection.dart';

class CheckConnection extends StatelessWidget {
  const CheckConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternetConnection(child: GoogleSignup());
  }
}
