import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_galery_app/thumbnail_service.dart';
import 'package:photo_galery_app/video_player_screen.dart';
import 'gallery_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<String> favoriteImages;

  const FavoritesScreen({super.key, required this.favoriteImages});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Set<String> selectedItems = {};
  bool selectionMode = false;

  void toggleSelection(String path) {
    setState(() {
      if (selectedItems.contains(path)) {
        selectedItems.remove(path);

        if (selectedItems.isEmpty) {
          selectionMode = false;
        }
      } else {
        selectedItems.add(path);
        selectionMode = true;
      }
    });
  }

  void toggleSelectAll() {
    setState(() {
      final allItems = widget.favoriteImages.toSet();

      if (selectedItems.length == allItems.length) {
        selectedItems.clear();
        selectionMode = false;
      } else {
        selectedItems = allItems;
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

  @override
  Widget build(BuildContext context) {
    if (widget.favoriteImages.isEmpty) {
      return const Center(child: Text("No favorites yet ❤️"));
    }

    return Scaffold(
      appBar: AppBar(
        title: selectionMode
            ? Text("${selectedItems.length} Selected")
            : const Text("Favorite"),
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: clearSelection,
              )
            : null,

        actions: [
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: toggleSelectAll,
            ),
        ],
      ),
      body: GridView.builder(
        cacheExtent: 1000,
        padding: const EdgeInsets.all(10),
        itemCount: widget.favoriteImages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),

        itemBuilder: (context, index) {
          final image = widget.favoriteImages[index];

          return GestureDetector(
            onTap: () {
              if (selectionMode) {
                toggleSelection(image);
                return;
              }
              if (image.endsWith(".mp4")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoDetailScreen(
                      videoList: widget.favoriteImages,
                      initialIndex: widget.favoriteImages.indexOf(image),
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      images: widget.favoriteImages
                          .where((e) => !e.endsWith(".mp4"))
                          .toList(),

                      initialIndex: widget.favoriteImages
                          .where((e) => !e.endsWith(".mp4"))
                          .toList()
                          .indexOf(image),
                    ),
                  ),
                );
              }
            },
            onLongPress: () {
              toggleSelection(image);
            },

            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),

                  child: image.endsWith(".mp4")
                      ? FutureBuilder(
                          future: ThumbnailService.generate(image),

                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(snapshot.data!),
                                  fit: BoxFit.cover,
                                  cacheWidth: 250,
                                  cacheHeight: 250,
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
                          image,
                          fit: BoxFit.cover,
                          cacheWidth: 250,
                          cacheHeight: 250,
                          gaplessPlayback: true,
                        ),
                ),

                if (selectionMode)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Icon(
                      selectedItems.contains(image)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: Colors.white,
                      size: 30,
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
