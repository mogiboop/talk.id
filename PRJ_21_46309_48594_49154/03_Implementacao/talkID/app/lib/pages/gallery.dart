import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_gallery.dart';
import 'package:talk_id/responsive/pages/tablet_gallery.dart';
import 'package:talk_id/responsive/responsive_layout.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveLayout(
        mobileBody: MobileGalleryPage(),
        tabletBody: TabletGalleryPage(),
        desktopBody: Scaffold(),),
    );
  }
}