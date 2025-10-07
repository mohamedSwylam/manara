import 'package:flutter/material.dart';
import 'custom_dialog_widget.dart';

class CustomDialogExample {
  // Example 1: Simple confirmation dialog
  static void showConfirmationDialog(BuildContext context) {
    CustomDialogWidget.show(
      context: context,
      title: "Delete Account",
      subtitle: "Are you sure you want to delete your account? This action cannot be undone.",
      firstChoiceText: "Delete",
      secondChoiceText: "Cancel",
      onFirstChoicePressed: () {
        Navigator.of(context).pop();
        // Handle delete action
        print("Delete action performed");
      },
      onSecondChoicePressed: () {
        Navigator.of(context).pop();
        // Handle cancel action
        print("Cancel action performed");
      },
    );
  }

  // Example 2: Logout confirmation dialog
  static void showLogoutDialog(BuildContext context) {
    CustomDialogWidget.show(
      context: context,
      title: "Logout",
      subtitle: "Are you sure you want to logout from your account?",
      firstChoiceText: "Logout",
      secondChoiceText: "Stay",
      onFirstChoicePressed: () {
        Navigator.of(context).pop();
        // Handle logout action
        print("Logout action performed");
      },
      onSecondChoicePressed: () {
        Navigator.of(context).pop();
        // Handle stay action
        print("Stay action performed");
      },
    );
  }

  // Example 3: Custom colors dialog
  static void showCustomColorsDialog(BuildContext context) {
    CustomDialogWidget.show(
      context: context,
      title: "Save Changes",
      subtitle: "Do you want to save your changes before leaving?",
      firstChoiceText: "Save",
      secondChoiceText: "Don't Save",
      firstChoiceColor: Colors.green,
      secondChoiceColor: Colors.orange,
      onFirstChoicePressed: () {
        Navigator.of(context).pop();
        // Handle save action
        print("Save action performed");
      },
      onSecondChoicePressed: () {
        Navigator.of(context).pop();
        // Handle don't save action
        print("Don't save action performed");
      },
    );
  }

  // Example 4: Simple dialog without subtitle
  static void showSimpleDialog(BuildContext context) {
    CustomDialogWidget.show(
      context: context,
      title: "Clear All Data",
      firstChoiceText: "Clear",
      secondChoiceText: "Cancel",
      onFirstChoicePressed: () {
        Navigator.of(context).pop();
        // Handle clear action
        print("Clear action performed");
      },
      onSecondChoicePressed: () {
        Navigator.of(context).pop();
        // Handle cancel action
        print("Cancel action performed");
      },
    );
  }
}

// Example usage in a widget
class DialogExampleWidget extends StatelessWidget {
  const DialogExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dialog Examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => CustomDialogExample.showConfirmationDialog(context),
              child: const Text('Show Confirmation Dialog'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => CustomDialogExample.showLogoutDialog(context),
              child: const Text('Show Logout Dialog'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => CustomDialogExample.showCustomColorsDialog(context),
              child: const Text('Show Custom Colors Dialog'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => CustomDialogExample.showSimpleDialog(context),
              child: const Text('Show Simple Dialog'),
            ),
          ],
        ),
      ),
    );
  }
}
