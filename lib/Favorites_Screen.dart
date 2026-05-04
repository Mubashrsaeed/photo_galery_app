import 'package:flutter/material.dart';
import 'gallery_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<String> favoriteImages;

  const FavoritesScreen({super.key, required this.favoriteImages});

  @override
  Widget build(BuildContext context) {
    if (favoriteImages.isEmpty) {
      return const Center(child: Text("No favorites yet ❤️"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: favoriteImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final image = favoriteImages[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetailScreen(images: favoriteImages, initialIndex: index),
              ),
            );
          },

          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(image, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
