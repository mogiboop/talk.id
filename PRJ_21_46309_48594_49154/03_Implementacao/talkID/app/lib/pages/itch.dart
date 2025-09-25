import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_itch.dart';
import 'package:talk_id/responsive/pages/tablet_itch.dart';
import 'package:talk_id/responsive/responsive_layout.dart';
class ItchPage extends StatefulWidget {
  const ItchPage({super.key});

  @override
  State<StatefulWidget> createState() => _ItchPageState();
}

class _ItchPageState extends State<ItchPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveLayout(
        mobileBody: MobileItchPage(),
        tabletBody: TabletItchPage(),
        desktopBody: Scaffold(),),
    );
  }
  
}