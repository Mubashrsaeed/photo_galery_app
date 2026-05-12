import 'package:flutter/material.dart';
import 'package:photo_galery_app/Favorites_Screen.dart';
import 'package:photo_galery_app/albums_screen.dart';
import 'gallery_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentIndex = 0;

  Set<String> favorites = {};

  // ✅ ALBUMS (SOURCE OF TRUTH)
  Map<String, List<String>> albums = {};

  void deleteAlbum(String albumName) {
    setState(() {
      albums.remove(albumName);
      albums = Map.from(albums);
      print("Deleting album: $albumName");
      print(albums.keys);
    });
  }

  void renameAlbum(String oldName, String newName) {
    if (albums.containsKey(oldName)) {
      setState(() {
        albums[newName] = albums[oldName]!;
        albums.remove(oldName);
      });
    }
  }

  void createAlbum(String name) {
    setState(() {
      albums[name] = [];
    });
  }

  void addToAlbum(String album, String image) {
    setState(() {
      albums[album]?.add(image);
    });
  }

  void removeFromAlbum(String albumName, String image) {
    setState(() {
      albums[albumName]?.remove(image);

      // optional cleanup if empty album
      if (albums[albumName]?.isEmpty ?? false) {
        albums.remove(albumName);
      }
    });
  }

  void toggleFavorite(String image) {
    setState(() {
      if (favorites.contains(image)) {
        favorites.remove(image);
      } else {
        favorites.add(image);
      }
    });
  }

  List<Widget> get screens => [
    GalleryScreen(
      favorites: favorites,
      onToggleFavorite: toggleFavorite,
      albums: albums,
      onAddToAlbum: addToAlbum, // 👈 NEW
    ),

    FavoritesScreen(favoriteImages: favorites.toList()),

    AlbumsScreen(
      // 👈 NEW SCREEN
      albums: albums,
      onCreateAlbum: createAlbum,
      onRemoveFromAlbum: removeFromAlbum,
      onRenameAlbum: renameAlbum,
      onDeleteAlbum: deleteAlbum,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Gallery"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Albums",
          ), // 👈
        ],
      ),
    );
  }
}
