import 'package:flutter/material.dart';

class CustomDialog {
  static Future<void> showAlertDialog(
      BuildContext context, String title, String content) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close AlertDialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
