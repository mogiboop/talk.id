import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_home.dart';
import 'package:talk_id/responsive/pages/tablet_home.dart';
import 'package:talk_id/responsive/responsive_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: ResponsiveLayout(
        mobileBody: MobileHomePage(),
        tabletBody: TabletHomePage(),
        desktopBody: Scaffold(),),
    );
  }
  
}