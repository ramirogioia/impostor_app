import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class RateUsDialog extends StatelessWidget {
  const RateUsDialog({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final String secondaryLabel;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String primaryLabel,
    required String secondaryLabel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => RateUsDialog(
        title: title,
        message: message,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: Text(title),
      content: Text(message),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(secondaryLabel),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await InAppReview.instance.openStoreListing();
          },
          child: Text(primaryLabel),
        ),
      ],
    );
  }
}
