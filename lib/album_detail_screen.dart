import 'package:flutter/material.dart';
import 'gallery_screen.dart'; // DetailScreen

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
    albumImages = List.from(widget.images); // ✅ FIX HERE
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
          ? const Center(child: Text("No images in this album"))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: albumImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),

              itemBuilder: (context, index) {
                final image = albumImages[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(
                          images: albumImages,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },

                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
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
                                removeImage(image);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(image, fit: BoxFit.cover),
                  ),
                );
              },
            ),
    );
  }
}
