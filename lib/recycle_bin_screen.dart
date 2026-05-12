import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_galery_app/gallery_screen.dart';
import 'package:photo_galery_app/recycle_bin_model.dart';
import 'package:photo_galery_app/recycle_bin_service.dart';
import 'package:photo_galery_app/video_player_screen.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key, required List<File> deletedFiles});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  List<RecycleBinItem> items = [];

  Set<String> selectedItems = {};
  bool selectionMode = false;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  // =========================
  // LOAD ITEMS
  // =========================

  Future<void> loadItems() async {
    final data = await RecycleBinService.getDeletedItems();

    setState(() {
      items = data.where((e) => e.path.isNotEmpty).toList();
    });
  }

  // =========================
  // SELECTION
  // =========================

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

  void selectAll() {
    setState(() {
      selectedItems = items.map((e) => e.path).toSet();

      selectionMode = true;
    });
  }

  void clearSelection() {
    setState(() {
      selectedItems.clear();
      selectionMode = false;
    });
  }

  // =========================
  // RESTORE
  // =========================

  Future<void> restoreItem(RecycleBinItem item) async {
    await RecycleBinService.removeFromRecycleBin(item.path);

    setState(() {
      items.remove(item);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("File Restored")));
  }

  // =========================
  // RESTORE ALL
  // =========================

  Future<void> restoreAllItems() async {
    for (var item in items) {
      await RecycleBinService.removeFromRecycleBin(item.path);
    }

    setState(() {
      items.clear();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("All files restored")));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("All items restored")));
  }

  // =========================
  // DELETE FOREVER
  // =========================

  Future<void> deleteForever(RecycleBinItem item) async {
    await RecycleBinService.removeFromRecycleBin(item.path);

    setState(() {
      items.remove(item);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("File Deleted")));
  }

  // =========================
  // EMPTY BIN
  // =========================

  Future<void> emptyBin() async {
    await RecycleBinService.emptyRecycleBin();

    setState(() {
      items.clear();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Recycle Bin emptied")));
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectionMode
            ? Text("${selectedItems.length} Selected")
            : const Text("Recycle Bin"),

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
              onPressed: selectAll,
            ),

          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: items.isEmpty ? null : restoreAllItems,
          ),

          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: emptyBin,
          ),
        ],
      ),

      body: items.isEmpty
          ? const Center(child: Text("Recycle Bin is empty"))
          : ListView.builder(
              itemCount: items.length,

              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  child: ListTile(
                    // =========================
                    // TAP
                    // =========================
                    onTap: () {
                      // SELECTION MODE
                      if (selectionMode) {
                        toggleSelection(item.path);
                        return;
                      }

                      // IMAGE OPEN
                      if (item.type == "image") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              images: [item.path],
                              initialIndex: 0,
                            ),
                          ),
                        );
                      }
                      // VIDEO OPEN
                      else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VideoPlayerScreen(videoPath: item.path),
                          ),
                        );
                      }
                    },

                    // =========================
                    // LONG PRESS
                    // =========================
                    onLongPress: () {
                      toggleSelection(item.path);
                    },

                    // =========================
                    // LEADING
                    // =========================
                    leading: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),

                          child: item.type == "image"
                              ? Image.asset(
                                  item.path,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,

                                  cacheWidth: 120,
                                  cacheHeight: 120,

                                  filterQuality: FilterQuality.low,

                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.black12,

                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: 40,
                                    ),
                                  ),
                                ),
                        ),

                        // CHECKBOX
                        if (selectionMode)
                          Positioned(
                            top: 0,
                            left: 0,

                            child: Icon(
                              selectedItems.contains(item.path)
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,

                              color: Colors.deepPurple,
                            ),
                          ),
                      ],
                    ),

                    // =========================
                    // TITLE
                    // =========================
                    title: Text(item.path.split('/').last),

                    subtitle: Text(item.type),

                    // =========================
                    // ACTIONS
                    // =========================
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore),

                          onPressed: () => restoreItem(item),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete),

                          onPressed: () => deleteForever(item),
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
