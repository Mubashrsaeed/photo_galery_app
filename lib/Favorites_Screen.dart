import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_galery_app/thumbnail_service.dart';
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
                          Image.file(File(snapshot.data!), fit: BoxFit.cover),

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
                  ),
          ),
        );
      },
    );
  }
}
