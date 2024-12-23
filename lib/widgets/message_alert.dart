import 'package:flutter/material.dart';

class MessageAlert extends StatelessWidget {
  final String title;

  const MessageAlert({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
            onPressed: () {
              // Dismiss the dialog
              Navigator.of(context).pop();
            },
            child: const Text("Ok")),
      ],
    );
  }
}
