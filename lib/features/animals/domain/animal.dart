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

const animals = <Animal>[
  Animal(
    id: 'dog',
    name: 'Cachorro',
    image: 'assets/animal_dog.png',
    sound: 'filhote_latindo.wav',
    clue: 'Eu faço au-au!',
  ),
  Animal(
    id: 'cat',
    name: 'Gato',
    image: 'assets/animal_cat.png',
    sound: 'gato.mp3',
    clue: 'Eu faço miau!',
  ),
  Animal(
    id: 'lion',
    name: 'Leão',
    image: 'assets/animal_lion.png',
    sound: 'leao.mp3',
    clue: 'Tenho uma juba ao redor da cabeça.',
  ),
  Animal(
    id: 'elephant',
    name: 'Elefante',
    image: 'assets/animal_elephant.png',
    sound: 'elefante.mp3',
    clue: 'Tenho uma tromba comprida.',
  ),
  Animal(
    id: 'cow',
    name: 'Vaca',
    image: 'assets/animal_cow.png',
    sound: 'cow.wav',
    clue: 'Eu faço muuu!',
  ),
  Animal(
    id: 'horse',
    name: 'Cavalo',
    image: 'assets/animal_horse.png',
    sound: 'horse.wav',
    clue: 'Tenho crina e gosto de galopar.',
  ),
  Animal(
    id: 'sheep',
    name: 'Ovelha',
    image: 'assets/animal_sheep.png',
    sound: 'sheep.wav',
    clue: 'Tenho lã fofinha e faço mééé!',
  ),
  Animal(
    id: 'duck',
    name: 'Pato',
    image: 'assets/animal_duck.png',
    sound: 'duck.wav',
    clue: 'Tenho bico largo e faço quá-quá!',
  ),
];

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
