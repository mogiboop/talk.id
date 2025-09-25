import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_pain.dart';
import 'package:talk_id/responsive/pages/tablet_pain.dart';
import 'package:talk_id/responsive/responsive_layout.dart';

class PainPage extends StatefulWidget {
  const PainPage({super.key});

  @override
  State<StatefulWidget> createState() => _PainPageState();
}

class _PainPageState extends State<PainPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveLayout(
        mobileBody: MobilePainPage(),
        tabletBody: TabletPainPage(),
        desktopBody: Scaffold(),),
    );
  }
  
}