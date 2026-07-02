import 'package:flutter/material.dart';

/// Primary action button with a built-in loading state.
/// Same pattern as a <Button loading={isSubmitting}> component
/// in a React design system — swaps its label for a spinner
/// automatically instead of every screen handling that manually.
class AcmsButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AcmsButton({
    super.key,
    required this.label,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Text(label),
      ),
    );
  }
}