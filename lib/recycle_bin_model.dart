class RecycleBinItem {
  final String path;
  final String type;
  final DateTime deletedAt;

  RecycleBinItem({
    required this.path,
    required this.type,
    required this.deletedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'type': type,
      'deletedAt': deletedAt.toIso8601String(),
    };
  }

  factory RecycleBinItem.fromJson(Map<String, dynamic> json) {
    return RecycleBinItem(
      path: json['path'],
      type: json['type'],
      deletedAt: DateTime.parse(json['deletedAt']),
    );
  }
}
