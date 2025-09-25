/*
import 'package:flutter/material.dart';
import 'package:talk_id/pages/com_keyboard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TtsPopup {
  static void show(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    print("cor: ${Theme.of(context).colorScheme.background}");
    showDialog(
      //barrierColor: Theme.of(context).colorScheme.background,
      context: context,
      builder: (BuildContext context) {
        // Return the dialog content
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            AppLocalizations.of(context)?.textToSpeech ?? '',
            style: textTheme.displaySmall,
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: const ComKeyboardPage(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)?.close ?? ''),
            ),
          ],
        );
      },
    );
  }
}
*/
