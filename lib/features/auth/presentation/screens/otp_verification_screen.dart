import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/acms_button.dart';
import '../../../../shared/widgets/acms_text_field.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String purpose;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.purpose,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  Timer? _resendTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // Counts down from 60 — same idea as a setInterval in a React
  // useEffect, cancelled on unmount via dispose() instead of a
  // cleanup function.
  void _startResendTimer() {
    _secondsRemaining = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _handleVerify() async {
    context.read<AuthProvider>().clearError();

    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().verifyOtp(
      phoneNumber: widget.phoneNumber,
      otpCode: _otpController.text.trim(),
      purpose: widget.purpose,
    );

    if (success && mounted) {
      // After verification, send them back to Login to sign in fresh
      // rather than auto-logging in — matches the flow from your
      // dev plan (After OTP verify → context.go(login)).
      context.go(RouteNames.login);
    }
  }

  Future<void> _handleResend() async {
    context.read<AuthProvider>().clearError();

    final success = await context.read<AuthProvider>().resendOtp(
      phoneNumber: widget.phoneNumber,
      purpose: widget.purpose,
    );

    if (success && mounted) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone Number')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sms_outlined, size: 56),
                const SizedBox(height: 12),
                Text(
                  'Enter the 6-digit code sent to',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  widget.phoneNumber,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                AcmsTextField(
                  controller: _otpController,
                  label: 'OTP Code',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'OTP is required.';
                    if (v.trim().length != 6) return 'OTP must be 6 digits.';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Column(
                      children: [
                        if (auth.errorMessage != null) ...[
                          Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        AcmsButton(
                          label: 'Verify',
                          isLoading: auth.isLoading,
                          onPressed: _handleVerify,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Resend link — disabled and showing a countdown until
                // it hits zero, same pattern as a disabled "Resend" link
                // with a ticking label in a React OTP form.
                Center(
                  child: _secondsRemaining > 0
                      ? Text(
                    'Resend code in $_secondsRemaining s',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                      : TextButton(
                    onPressed: _handleResend,
                    child: const Text('Resend Code'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}