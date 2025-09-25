import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_needs.dart';
import 'package:talk_id/responsive/pages/tablet_needs.dart';
import 'package:talk_id/responsive/responsive_layout.dart';
class NeedsPage extends StatefulWidget {
  const NeedsPage({super.key});

  @override
  State<StatefulWidget> createState() => _NeedsPageState();
}

class _NeedsPageState extends State<NeedsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: ResponsiveLayout(
        mobileBody: MobileNeedsPage(),
        tabletBody: TabletNeedsPage(),
        desktopBody: Scaffold(),),
    );
  }

}