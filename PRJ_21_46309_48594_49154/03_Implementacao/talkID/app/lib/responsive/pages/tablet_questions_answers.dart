import 'package:flutter/material.dart';
import 'package:talk_id/pages/Q&A/quick_chat.dart';
import 'package:talk_id/pages/Q&A/yes_no.dart';
import 'package:talk_id/pages/home.dart';
import 'package:talk_id/responsive/pages/tablet_tts_pop_up.dart';
import 'package:talk_id/utils/boxdata.dart';
import 'package:talk_id/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TabletQAPage extends StatefulWidget {
  const TabletQAPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabletQAPageState();
}

class _TabletQAPageState extends State<TabletQAPage> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final List<BoxData> boxDataList = [
      BoxData(
          icon: Icons.check_circle_rounded,
          text: AppLocalizations.of(context)?.yesNo ?? ''),
      BoxData(
          icon: Icons.question_mark_rounded,
          text: AppLocalizations.of(context)?.quickChat ?? ''),
    ];
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          AppLocalizations.of(context)?.qA ?? '',
          style: textTheme.displayMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ),
          },
        ),
      ),
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = _previousScale * details.scale;
          });
        },
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(boxDataList.length, (index) {
                    BoxData boxData = boxDataList[index];
                    return InkWell(
                      onTap: () {
                        _handleInkWellTap(index);
                      },
                      child: Container(
                        margin: EdgeInsets.all(
                            calculateMargin(constraints.maxWidth)),
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.shadow,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              boxData.icon,
                              size: calculateIconSize(constraints.maxWidth),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              boxData.text,
                              textAlign: TextAlign.center,
                              style: textTheme.displaySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
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

  void _handleInkWellTap(int index) {
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const YesNoAnswersPage()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const QuickChatPage()));
        break;
      default:
        print('InkWell at index $index tapped');
    }
  }
}
