import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_galery_app/thumbnail_service.dart';
import 'package:photo_galery_app/video_player_screen.dart';
import 'package:photo_view/photo_view.dart';

class GalleryScreen extends StatefulWidget {
  final Set<String> favorites;
  final Function(String) onToggleFavorite;
  final Map<String, List<String>> albums;
  final Function(String, String) onAddToAlbum;

  const GalleryScreen({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.albums,
    required this.onAddToAlbum,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<Map<String, String>> media = [
    {"type": "image", "path": "assets/images/image1.jpeg"},
    {"type": "image", "path": "assets/images/image2.jpeg"},
    {"type": "image", "path": "assets/images/image3.jpeg"},
    {"type": "image", "path": "assets/images/image4.jpeg"},
    {"type": "image", "path": "assets/images/image5.jpeg"},
    {"type": "image", "path": "assets/images/image6.jpeg"},
    {"type": "image", "path": "assets/images/image7.jpeg"},
    {"type": "image", "path": "assets/images/image8.jpeg"},
    {"type": "image", "path": "assets/images/image9.jpeg"},
    {"type": "image", "path": "assets/images/image10.jpeg"},
    {"type": "image", "path": "assets/images/image11.jpeg"},
    {"type": "image", "path": "assets/images/image12.jpeg"},
    {"type": "image", "path": "assets/images/image13.jpeg"},
    {"type": "image", "path": "assets/images/image14_aspire_zone_qatar.jpeg"},

    {"type": "video", "path": "assets/videos/astore_gilgit.mp4"},
    {"type": "video", "path": "assets/videos/chunda_valley.mp4"},
    {"type": "video", "path": "assets/videos/lusail_qatar.mp4"},
    {"type": "video", "path": "assets/videos/north_pakistan.mp4"},
    {"type": "video", "path": "assets/videos/skardu_valley.mp4"},
    {"type": "video", "path": "assets/videos/bu_hamur.mp4"},
    {"type": "video", "path": "assets/videos/video2.mp4"},
    {"type": "video", "path": "assets/videos/video1.mp4"},
  ];

  TextEditingController searchController = TextEditingController();
  String query = "";

  List<Map<String, String>> get filteredMedia {
    return media.where((item) {
      return item["path"]!.toLowerCase().contains(query);
    }).toList();
  }

  // ✅ FIXED DELETE + SHARE
  void showImageActions(BuildContext context, String image) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) {
        return Wrap(
          children: [
            // 📁 ADD TO ALBUM
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text("Add to Album"),
              onTap: () {
                Navigator.pop(bottomContext);

                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Wrap(
                      children: widget.albums.keys.map((album) {
                        return ListTile(
                          title: Text(album),
                          onTap: () {
                            widget.onAddToAlbum(album, image);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Added to $album")),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),

            // 📤 SHARE
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share"),
              onTap: () {
                Navigator.pop(bottomContext);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Sharing $image")));
              },
            ),

            // 🗑 DELETE
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete"),
              onTap: () {
                Navigator.pop(bottomContext);

                setState(() {
                  media.removeWhere((e) => e["path"] == image);
                });

                widget.onToggleFavorite(image); // sync

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Deleted")));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),

      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search images...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  query = value.toLowerCase();
                });
              },
            ),
          ),

          // ❤️ FAVORITE BUTTON
          Expanded(
            child: GridView.builder(
              cacheExtent: 1000,
              padding: const EdgeInsets.all(10),
              itemCount: filteredMedia.length,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),

              itemBuilder: (context, index) {
                final item = filteredMedia[index];
                final path = item["path"]!;

                return GestureDetector(
                  onTap: () {
                    if (item["type"] == "image") {
                      final imagesOnly = filteredMedia
                          .where((e) => e["type"] == "image")
                          .map((e) => e["path"]!)
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            images: imagesOnly,
                            initialIndex: imagesOnly.indexOf(path),
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(videoPath: path),
                        ),
                      );
                    }
                  },

                  onLongPress: () {
                    showImageActions(context, path);
                  },

                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: item["type"] == "image"
                            ? Image.asset(
                                item["path"]!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                cacheWidth: 300,
                                cacheHeight: 300,
                                filterQuality: FilterQuality.low,
                              )
                            : FutureBuilder<String?>(
                                future: ThumbnailService.generate(path),
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

                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return Container(
                                      color: Colors.black12,
                                      child: const Center(
                                        child: Icon(Icons.video_library),
                                      ),
                                    );
                                  }

                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(snapshot.data!),
                                        fit: BoxFit.cover,
                                      ),

                                      Container(color: Colors.black26),

                                      const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      // ❤️ FAVORITE BUTTON
                      Positioned(
                        right: 5,
                        top: 5,
                        child: IconButton(
                          icon: Icon(
                            widget.favorites.contains(path)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            widget.onToggleFavorite(path);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const DetailScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PageController controller;
  late PhotoViewController _photoViewController;

  @override
  void initState() {
    super.initState();

    controller = PageController(initialPage: widget.initialIndex);
    _photoViewController = PhotoViewController();
  }

  @override
  void dispose() {
    controller.dispose();
    _photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {}
          return false;
        },

        child: PageView.builder(
          controller: controller,
          itemCount: widget.images.length,

          itemBuilder: (context, index) {
            return GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! > 300) {
                  Navigator.pop(context); // 👈 swipe down close
                }
              },

              onDoubleTap: () {
                final currentScale = _photoViewController.scale ?? 1.0;

                if (currentScale > 1.0) {
                  _photoViewController.scale = 1.0;
                } else {
                  _photoViewController.scale = 2.5;
                }
              },

              child: PhotoView(
                controller: _photoViewController,
                imageProvider: ResizeImage(
                  AssetImage(widget.images[index]),
                  width: 1200,
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              ),
            );
          },
        ),
      ),
    );
  }
}
