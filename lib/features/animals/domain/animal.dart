class Animal {
  const Animal({
    required this.id,
    required this.name,
    required this.image,
    required this.sound,
    required this.clue,
  });
  final String id;
  final String name;
  final String image;
  final String sound;
  final String clue;
  String get initial => name[0].toUpperCase();
}

String normalizeWords(String value) => value
    .toLowerCase()
    .trim()
    .replaceAll('ã', 'a')
    .replaceAll('á', 'a')
    .replaceAll('â', 'a')
    .replaceAll('é', 'e')
    .replaceAll('ê', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ô', 'o')
    .replaceAll('õ', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ç', 'c')
    .replaceAll(RegExp(r'[^a-z\s]'), '')
    .replaceAll(RegExp(r'\s+'), ' ');
