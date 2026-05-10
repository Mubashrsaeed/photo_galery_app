import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_galery_app/gallery_screen.dart';
import 'package:photo_galery_app/thumbnail_service.dart';
import 'package:photo_galery_app/video_player_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumName;
  final List<String> images;
  final Function(String album, String image) onRemove;

  const AlbumDetailScreen({
    super.key,
    required this.albumName,
    required this.images,
    required this.onRemove,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  late List<String> albumImages;

  @override
  void initState() {
    super.initState();
    albumImages = List.from(widget.images);
  }

  void removeImage(String image) {
    setState(() {
      albumImages.remove(image);
    });

    widget.onRemove(widget.albumName, image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.albumName)),

      body: albumImages.isEmpty
          ? const Center(child: Text("No media in this album"))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              cacheExtent: 1000,
              itemCount: albumImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),

              itemBuilder: (context, index) {
                final media = albumImages[index];
                final isVideo = media.endsWith(".mp4");

                return GestureDetector(
                  onTap: () {
                    // ✅ VIDEO OPEN
                    if (isVideo) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(videoPath: media),
                        ),
                      );
                    }
                    // ✅ IMAGE OPEN
                    else {
                      final imagesOnly = albumImages
                          .where((e) => !e.endsWith(".mp4"))
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            images: imagesOnly,
                            initialIndex: imagesOnly.indexOf(media),
                          ),
                        ),
                      );
                    }
                  },

                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: const Text("Remove from Album"),
                              onTap: () {
                                Navigator.pop(context);
                                removeImage(media);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),

                    child: isVideo
                        // ✅ VIDEO THUMBNAIL
                        ? FutureBuilder<String?>(
                            future: ThumbnailService.generate(media),

                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data == null) {
                                return Container(
                                  color: Colors.black12,
                                  child: const Center(
                                    child: Icon(Icons.video_library, size: 50),
                                  ),
                                );
                              }

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(snapshot.data!),
                                    fit: BoxFit.cover,
                                    cacheWidth: 300,
                                    cacheHeight: 300,
                                  ),

                                  Container(color: Colors.black26),

                                  const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        // ✅ IMAGE
                        : Image.asset(
                            media,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            cacheHeight: 300,
                            filterQuality: FilterQuality.low,
                          ),
                  ),
                );
              },
            ),
    );
  }
}
