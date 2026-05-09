import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailService {
  static Future<String?> generate(String assetVideoPath) async {
    try {
      // 🔥 Get temp directory
      final tempDir = await getTemporaryDirectory();

      // 🔥 Create temp video file
      final fileName = assetVideoPath.split('/').last;

      final tempVideo = File('${tempDir.path}/$fileName');

      // 🔥 Copy asset video to temp storage
      final byteData = await rootBundle.load(assetVideoPath);

      await tempVideo.writeAsBytes(byteData.buffer.asUint8List());

      // 🔥 Generate thumbnail
      final thumb = await VideoThumbnail.thumbnailFile(
        video: tempVideo.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 25,
      );

      return thumb;
    } catch (e) {
      print("Thumbnail Error: $e");
      return null;
    }
  }
}
