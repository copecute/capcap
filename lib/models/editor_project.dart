class EditorProject {
  final String id;
  final String name;
  final String type; // video | photo
  final DateTime createdAt;
  final int assetCount;
  final String? thumbnailPath;

  const EditorProject({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.assetCount,
    this.thumbnailPath,
  });
}
