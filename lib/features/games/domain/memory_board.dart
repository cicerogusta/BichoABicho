import 'dart:math';

import '../../animals/domain/animal.dart';

class MemoryCard {
  const MemoryCard({required this.id, required this.animal});

  final int id;
  final Animal animal;
}

enum MemorySelection { ignored, revealed, match, mismatch }

/// Card identities remain stable when their positions change.
class MemoryBoard {
  MemoryBoard(List<Animal> animals, {Random? random}) {
    if (animals.length != pairCount ||
        animals.map((animal) => animal.id).toSet().length != animals.length) {
      throw ArgumentError('Expected three distinct animal pairs.');
    }
    _cards = [
      for (var i = 0; i < animals.length * 2; i++)
        MemoryCard(id: i, animal: animals[i ~/ 2]),
    ];
    shuffle(random ?? Random());
  }

  static const pairCount = 3;

  late List<MemoryCard> _cards;
  final Set<int> _matched = {};
  final List<int> _selected = [];
  List<MemoryCard> get cards => List.unmodifiable(_cards);
  int get pairsFound => _matched.length ~/ 2;
  bool get complete => _matched.length == _cards.length;
  bool isRevealed(int id) => _matched.contains(id) || _selected.contains(id);
  bool isMatched(int id) => _matched.contains(id);

  void shuffle(Random random) {
    final candidates = [..._cards]..shuffle(random);
    final arranged = <MemoryCard>[];
    final used = <int>{};

    // Search a randomized order instead of retrying random shuffles indefinitely.
    // Every card moves, and equal animals never occupy consecutive positions.
    bool arrange() {
      if (arranged.length == candidates.length) return true;
      for (final card in candidates) {
        if (used.contains(card.id) ||
            card.id == _cards[arranged.length].id ||
            (arranged.isNotEmpty &&
                arranged.last.animal.id == card.animal.id)) {
          continue;
        }
        arranged.add(card);
        used.add(card.id);
        if (arrange()) return true;
        arranged.removeLast();
        used.remove(card.id);
      }
      return false;
    }

    if (!arrange()) throw StateError('Unable to arrange the memory cards.');
    _cards = arranged;
  }

  MemorySelection select(int id) {
    if (_selected.length == 2 ||
        isRevealed(id) ||
        !_cards.any((card) => card.id == id)) {
      return MemorySelection.ignored;
    }
    _selected.add(id);
    if (_selected.length == 1) return MemorySelection.revealed;
    final first = _cards.firstWhere((card) => card.id == _selected.first);
    final second = _cards.firstWhere((card) => card.id == id);
    if (first.animal.id != second.animal.id) return MemorySelection.mismatch;
    _matched.addAll(_selected);
    _selected.clear();
    return MemorySelection.match;
  }

  void hideSelection() => _selected.clear();
}
