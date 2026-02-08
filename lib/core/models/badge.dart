class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath; // Using emoji for now, or asset path
  final bool isSecret;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.isSecret = false,
  });
}
