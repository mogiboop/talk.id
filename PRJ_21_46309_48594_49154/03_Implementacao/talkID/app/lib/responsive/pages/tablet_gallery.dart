import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:talk_id/pages/asset_thumbnail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:talk_id/pages/home.dart';

class TabletGalleryPage extends StatefulWidget {
  const TabletGalleryPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabletGalleryPageState();
}

class _TabletGalleryPageState extends State<TabletGalleryPage> {
  List<AssetEntity> assets = [];

  Future<void> _fetchAssets() async {
    assets = await PhotoManager.getAssetListRange(start: 0, end: 100000);

    setState(() {});
  }

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      onPopInvoked: (dipPop) {
        // Handle back button press
        if (!dipPop) {
          return Navigator.pop(context, 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            AppLocalizations.of(context)?.gallery ?? '',
            style: textTheme.displayMedium,),
          centerTitle: true,
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
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemCount: assets.length,
          itemBuilder: (_, index) {
            return AssetThumbnail(
              asset: assets[index],
            );
          },
        ),
      ),
    );
  }
}
