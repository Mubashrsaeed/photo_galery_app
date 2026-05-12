import 'package:flutter/material.dart';
import 'package:photo_galery_app/album_detail_screen.dart';

class AlbumsScreen extends StatelessWidget {
  final Map<String, List<String>> albums;
  final Function(String) onCreateAlbum;
  final Function(String, String) onRemoveFromAlbum;
  final Function(String oldName, String newName) onRenameAlbum;
  final Function(String albumName) onDeleteAlbum;

  const AlbumsScreen({
    super.key,
    required this.albums,
    required this.onCreateAlbum,
    required this.onRemoveFromAlbum,
    required this.onRenameAlbum,
    required this.onDeleteAlbum,
  });

  // ---------------- COLLAGE ----------------

  Widget _buildCollage(List<String> images) {
    if (images.isEmpty) {
      return const Center(child: Icon(Icons.folder, size: 50));
    }

    if (images.first.endsWith(".mp4")) {
      return const Center(
        child: Icon(Icons.play_circle_fill, size: 60, color: Colors.black54),
      );
    }

    if (images.length == 1) {
      return Image.asset(images[0], fit: BoxFit.cover);
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(child: Image.asset(images[0], fit: BoxFit.cover)),
          Expanded(child: Image.asset(images[1], fit: BoxFit.cover)),
        ],
      );
    }

    return Column(
      children: [
        Expanded(child: Image.asset(images[0], fit: BoxFit.cover)),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.asset(images[1], fit: BoxFit.cover)),
              Expanded(child: Image.asset(images[2], fit: BoxFit.cover)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- RENAME ----------------

  void _renameAlbum(BuildContext context, String oldName) {
    TextEditingController controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rename Album"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text.trim();

                if (newName.isNotEmpty && newName != oldName) {
                  onRenameAlbum(oldName, newName);
                }

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- DELETE CONFIRMATION ----------------

  void _deleteAlbum(BuildContext context, String albumName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Album"),
          content: Text("Are you sure you want to delete '$albumName'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onDeleteAlbum(albumName); // ✅ REAL DELETE
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Albums")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController controller = TextEditingController();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Create Album"),
                content: TextField(controller: controller),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      onCreateAlbum(controller.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text("Create"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: albums.keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),

        itemBuilder: (context, index) {
          final albumName = albums.keys.elementAt(index);
          final images = albums[albumName] ?? [];

          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlbumDetailScreen(
                        albumName: albumName,
                        images: List.from(images),
                        onRemove: onRemoveFromAlbum,
                      ),
                    ),
                  );
                },

                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: _buildCollage(images),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              albumName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("${images.length} images"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------- MENU ----------------
              Positioned(
                top: 5,
                right: 5,
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "rename") {
                      _renameAlbum(context, albumName);
                    }

                    if (value == "delete") {
                      _deleteAlbum(context, albumName); // ✅ FIXED
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: "rename", child: Text("Rename")),
                    PopupMenuItem(value: "delete", child: Text("Delete")),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
