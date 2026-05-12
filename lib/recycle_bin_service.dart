import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photo_galery_app/recycle_bin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecycleBinService {
  static const String key = 'recycle_bin';

  static Future<List<RecycleBinItem>> getDeletedItems() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(key) ?? [];

    List<RecycleBinItem> items = [];

    for (var e in data) {
      try {
        final decoded = jsonDecode(e);

        items.add(RecycleBinItem.fromJson(decoded));
      } catch (error) {
        // skip corrupted item instead of crashing app
        continue;
      }
    }

    return items;
  }

  static Future<void> addToRecycleBin(RecycleBinItem item) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(key) ?? [];

    try {
      data.add(jsonEncode(item.toJson()));
      await prefs.setStringList(key, data);
    } catch (e) {
      debugPrint("Failed to add item: $e");
    }
  }

  static Future<void> removeFromRecycleBin(String path) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(key) ?? [];

    data.removeWhere((element) {
      final item = RecycleBinItem.fromJson(jsonDecode(element));

      return item.path == path;
    });

    await prefs.setStringList(key, data);
  }

  static Future<void> emptyRecycleBin() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }
}
