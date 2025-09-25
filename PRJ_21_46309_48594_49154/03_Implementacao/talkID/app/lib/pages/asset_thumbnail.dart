import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:talk_id/pages/image_view.dart';
import 'package:talk_id/pages/video_view.dart';

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({super.key, required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
        future: asset.thumbnailData.then((value) => value!),
        builder: (_, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) return const CircularProgressIndicator();
          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) {
                  if (asset.type == AssetType.image) {
                    return ImageView(imageFile: asset.file);
                  } else {
                    //return const CircularProgressIndicator();
                    return VideoView(videoFile: asset.file);
                  }
                },
              ));
            },
            child: Stack(
              children: [
                Positioned.fill(child: Image.memory(bytes, fit: BoxFit.cover)),
                if (asset.type == AssetType.video)
                  Center(
                    child: Container(
                      color: Colors.blue,
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  )
              ],
            ),
          );
        });
  }
}
