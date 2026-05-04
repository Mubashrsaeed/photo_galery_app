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

      body: ListView(
        children: albums.keys.map((albumName) {
          return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(albumName),
            trailing: Text("${albums[albumName]?.length ?? 0} images"),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlbumDetailScreen(
                    albumName: albumName,
                    images: List.from(albums[albumName] ?? []),

                    // ✅ CONNECT REMOVE FUNCTION
                    onRemove: onRemoveFromAlbum,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
