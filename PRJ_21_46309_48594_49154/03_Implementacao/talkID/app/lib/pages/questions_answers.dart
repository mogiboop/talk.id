import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_questions_answers.dart';
import 'package:talk_id/responsive/pages/tablet_questions_answers.dart';

import '../responsive/responsive_layout.dart';

class QAPage extends StatefulWidget {
  const QAPage({super.key});

  @override
  State<StatefulWidget> createState() => _QAPageState();
}

class _QAPageState extends State<QAPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: ResponsiveLayout(
        mobileBody: MobileQAPage(),
        tabletBody: TabletQAPage(),
        desktopBody: Scaffold(),
      ),
    );
  }
}
