import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_yes_no.dart';
import 'package:talk_id/responsive/pages/tablet_yes_no.dart';
import 'package:talk_id/responsive/responsive_layout.dart';

class YesNoAnswersPage extends StatefulWidget {
  const YesNoAnswersPage({super.key});

  @override
  State<StatefulWidget> createState() => _YesNoAnswersPageState();
}

class _YesNoAnswersPageState extends State<YesNoAnswersPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: ResponsiveLayout(
        mobileBody: MobileYesNoAnswersPage(),
        tabletBody: TabletYesNoAnswersPage(),
        desktopBody: Scaffold(),
      ),
    );
  }
}
