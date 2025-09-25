import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_id/pages/questions_answers.dart';
import 'package:talk_id/responsive/pages/tablet_com_keyboard.dart';
import 'package:talk_id/responsive/pages/tablet_tts_pop_up.dart';
import 'package:talk_id/utils/boxdatayesno.dart';
import 'package:talk_id/utils/utils.dart';
import 'package:talk_id/provider/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MobileYesNoAnswersPage extends StatelessWidget {
  const MobileYesNoAnswersPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    var languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)?.yesNoAnswers ?? '',
            style: textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QAPage()),
            ),
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    TabletComKeyboardPage.speak(
                      AppLocalizations.of(context)?.yes ?? '',
                      languageProvider.locale.languageCode,
                    );
                  },
                  child: BoxDataYesNo(
                    width: 200,
                    height: 200,
                    borderRadius: 20.0,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)?.yes ?? '',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    TabletComKeyboardPage.speak(
                      AppLocalizations.of(context)?.no ?? '',
                      languageProvider.locale.languageCode,
                    );
                  },
                  child: BoxDataYesNo(
                    width: 200,
                    height: 200,
                    borderRadius: 20.0,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)?.no ?? '',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          const Positioned(
            bottom: 10.0,
            left: 40.0,
            child: FloatingActionButton(
              heroTag: "SOS",
              onPressed: sendSOS,
              child: Icon(Icons.sos),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: "TTS",
              onPressed: () {
                TabletTtsPopup.show(context);
              },
              child: const Icon(Icons.record_voice_over),
            ),
          ),
        ],
      ),
    );
  }
}
