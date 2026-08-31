import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// A reusable widget that shows one of three states: loading, an error, or an
/// empty state. Centralising this keeps error/empty/loading handling
/// consistent across every screen (a mandatory requirement).
class StateView extends StatelessWidget {
  const StateView.loading({super.key})
      : message = null,
        icon = null,
        isError = true,
        showLoading = true,
        onRetry = null;

  const StateView.error(this.message, {super.key, this.onRetry})
      : icon = Icons.error_outline,
        isError = true,
        showLoading = false;

  const StateView.empty(this.message, {super.key, this.icon = Icons.inbox})
      : isError = false,
        showLoading = false,
        onRetry = null;

  /// The message to display.
  final String? message;

  /// Optional icon (mainly used by empty/error states).
  final IconData? icon;

  /// Whether this is an error state (affects colouring).
  final bool isError;

  /// When true, shows a spinner instead of the icon.
  final bool showLoading;

  /// Optional retry callback for error states.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLoading)
              const CircularProgressIndicator()
            else
              Icon(
                icon,
                size: 64,
                color: isError ? Colors.redAccent : AppColors.textSecondary,
              ),
            const SizedBox(height: 16),
            Text(
              message ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
