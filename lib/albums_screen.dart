import 'package:flutter/material.dart';
import 'package:photo_galery_app/album_detail_screen.dart';

class AlbumsScreen extends StatelessWidget {
  final Map<String, List<String>> albums;
  final Function(String) onCreateAlbum;
  final Function(String, String) onRemoveFromAlbum;

  const AlbumsScreen({
    super.key,
    required this.albums,
    required this.onCreateAlbum,
    required this.onRemoveFromAlbum,
  });

  Widget _buildCollage(List<String> images) {
    if (images.isEmpty) {
      return const Center(child: Icon(Icons.folder, size: 50));
    }

    // ✅ VIDEO SUPPORT
    if (images.first.endsWith(".mp4")) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.play_circle_fill, size: 60, color: Colors.black54),
        ),
      );
    }

    // ✅ SINGLE IMAGE
    if (images.length == 1) {
      return Image.asset(
        images[0],
        fit: BoxFit.cover,
        cacheWidth: 300,
        cacheHeight: 300,
        filterQuality: FilterQuality.low,
      );
    }

    // ✅ TWO IMAGES
    if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: Image.asset(
              images[0],
              fit: BoxFit.cover,
              cacheWidth: 300,
              cacheHeight: 300,
            ),
          ),
          Expanded(
            child: Image.asset(
              images[1],
              fit: BoxFit.cover,
              cacheWidth: 300,
              cacheHeight: 300,
            ),
          ),
        ],
      );
    }

    // ✅ THREE+ IMAGES
    return Column(
      children: [
        Expanded(
          child: Image.asset(
            images[0],
            fit: BoxFit.cover,
            width: double.infinity,
            cacheWidth: 300,
            cacheHeight: 300,
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Image.asset(
                  images[1],
                  fit: BoxFit.cover,
                  cacheWidth: 300,
                  cacheHeight: 300,
                ),
              ),
              Expanded(
                child: Image.asset(
                  images[2],
                  fit: BoxFit.cover,
                  cacheWidth: 300,
                  cacheHeight: 300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Albums")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController controller = TextEditingController();

              return AlertDialog(
                title: const Text("Create Album"),
                content: TextField(controller: controller),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      onCreateAlbum(controller.text);
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

          return GestureDetector(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📸 IMAGE COLLAGE
                  Expanded(
                    child: images.isEmpty
                        ? const Center(child: Icon(Icons.folder, size: 50))
                        : ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: _buildCollage(images),
                          ),
                  ),

                  // 📝 TEXT INFO
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          albumName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("${images.length} images"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
