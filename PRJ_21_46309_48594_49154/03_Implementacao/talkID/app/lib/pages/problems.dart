import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_problems.dart';
import 'package:talk_id/responsive/pages/tablet_problems.dart';
import 'package:talk_id/responsive/responsive_layout.dart';

class ProblemsPage extends StatefulWidget {
  const ProblemsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProblemsPageState();
}

class _ProblemsPageState extends State<ProblemsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: ResponsiveLayout(
        mobileBody: MobileProblemsPage(),
        tabletBody: TabletProblemsPage(),
        desktopBody: Scaffold(),),
    );
  }
    
}