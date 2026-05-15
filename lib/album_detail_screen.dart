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
  List<String> get videoList {
    return albumImages.where((e) => e.endsWith(".mp4")).toList();
  }

  List<String> get imageList {
    return albumImages.where((e) => !e.endsWith(".mp4")).toList();
  }

  Map<String, List<String>> albums = {};

  Set<String> selectedItems = {};
  bool selectionMode = false;

  @override
  void initState() {
    super.initState();
    albumImages = List.from(widget.images);
  }

  void deleteAlbum(String albumName) {
    setState(() {
      albums.remove(albumName);
    });
  }

  // ---------------- SELECTION ----------------

  void toggleSelection(String media) {
    setState(() {
      if (selectedItems.contains(media)) {
        selectedItems.remove(media);
        if (selectedItems.isEmpty) {
          selectionMode = false;
        }
      } else {
        selectedItems.add(media);
        selectionMode = true;
      }
    });
  }

  void toggleSelectAll() {
    setState(() {
      if (selectedItems.length == albumImages.length) {
        // ❌ Already all selected → unselect all
        selectedItems.clear();
        selectionMode = false;
      } else {
        // ✅ Select all
        selectedItems = albumImages.toSet();
        selectionMode = true;
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedItems.clear();
      selectionMode = false;
    });
  }

  // ---------------- ACTIONS ----------------

  void deleteSelectedItems() {
    setState(() {
      albumImages.removeWhere((item) => selectedItems.contains(item));

      selectedItems.clear();
      selectionMode = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Selected items deleted")));
  }

  void addSelectedToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${selectedItems.length} items added to favorites"),
      ),
    );

    clearSelection();
  }

  void shareSelectedItems() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sharing ${selectedItems.length} items")),
    );

    clearSelection();
  }

  // ---------------- REMOVE SINGLE ITEM ----------------

  void removeImage(String image) {
    setState(() {
      albumImages.remove(image);
    });

    widget.onRemove(widget.albumName, image);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectionMode
            ? Text("${selectedItems.length} Selected")
            : Text(widget.albumName),

        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: clearSelection,
              )
            : null,

        actions: [
          if (selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: addSelectedToFavorites,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: shareSelectedItems,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteSelectedItems,
            ),
            IconButton(
              icon: Icon(
                selectedItems.length == albumImages.length
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              onPressed: toggleSelectAll,
            ),
          ],
        ],
      ),

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
                  onLongPress: () {
                    toggleSelection(media);
                  },

                  onTap: () {
                    if (selectionMode) {
                      toggleSelection(media);
                      return;
                    }

                    if (isVideo) {
                      final videos = videoList;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoDetailScreen(
                            videoList: videos,
                            initialIndex: videos.indexOf(media),
                          ),
                        ),
                      );
                    } else {
                      final imagesOnly = imageList;

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

                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),

                        child: isVideo
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

                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return Container(
                                      color: Colors.black12,
                                      child: const Center(
                                        child: Icon(
                                          Icons.video_library,
                                          size: 50,
                                        ),
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
                                        gaplessPlayback: true,
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
                            : Image.asset(
                                media,
                                fit: BoxFit.cover,
                                cacheWidth: 300,
                                cacheHeight: 300,
                              ),
                      ),

                      // ---------------- SELECTION ICON ----------------
                      if (selectionMode)
                        Positioned(
                          top: 5,
                          left: 5,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              selectedItems.contains(media)
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
