import 'package:flutter/material.dart';
import 'package:talk_id/utils/utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget desktopBody;

  const ResponsiveLayout({super.key, 
    required this.mobileBody,
    required this.tabletBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if(orientation == Orientation.portrait){
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < mobileWidth) {
                return mobileBody;
              } else if (constraints.maxWidth < tabletWidth) {
                return tabletBody;
              } else {
                return desktopBody;
              }
            },
          );
        }
        else{
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight < mobileWidth) {
                return mobileBody;
              } else if (constraints.maxHeight < tabletWidth) {
                return tabletBody;
              } else {
                return desktopBody;
              }
            },
          );
        }
      },
    );
  }
}