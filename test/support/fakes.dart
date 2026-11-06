import 'dart:async';

import 'package:bicho_a_bicho/core/services/animal_audio.dart';
import 'package:bicho_a_bicho/core/services/animal_speech.dart';
import 'package:bicho_a_bicho/features/account/domain/account_repository.dart';
import 'package:bicho_a_bicho/features/settings/domain/settings_repository.dart';

class MemorySettingsRepository implements SettingsRepository {
  Map<String, Object> values = {};
  bool fail = false;
  @override
  Future<Map<String, Object>> load() async {
    if (fail) throw Exception('Storage unavailable');
    return Map.of(values);
  }

  @override
  Future<void> save(Map<String, Object> values) async {
    if (fail) throw Exception('Storage unavailable');
    this.values = Map.of(values);
  }
}

class FakeAudio implements AnimalAudio {
  int plays = 0;
  final List<String> playedAssets = [];
  int stops = 0;
  bool fail = false;
  bool disposed = false;
  @override
  Future<void> play(String asset) async {
    plays++;
    playedAssets.add(asset);
    if (fail) throw Exception('Audio unavailable');
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class FakeSpeech implements AnimalSpeech {
  bool available = true;
  Completer<bool>? initialization;
  int listens = 0;
  int cancels = 0;
  void Function(String)? onFinal;
  void Function()? onDone;
  void Function()? onError;
  @override
  Future<bool> listen({
    required void Function(String) onFinal,
    required void Function() onDone,
    required void Function() onError,
  }) async {
    listens++;
    this.onFinal = onFinal;
    this.onDone = onDone;
    this.onError = onError;
    return initialization == null ? available : initialization!.future;
  }

  @override
  Future<void> cancel() async {
    cancels++;
  }
}

class FakeAccountRepository implements AccountRepository {
  String? name;
  AccountFailure? failure;
  int signIns = 0;
  @override
  Future<String?> currentName() async => name;
  @override
  Future<String> register(String name, String email, String password) async {
    if (failure != null) throw failure!;
    return this.name = name;
  }

  @override
  Future<String> signIn(String email, String password) async {
    signIns++;
    if (failure != null) throw failure!;
    return name = 'Responsável';
  }

  @override
  Future<void> signOut() async {
    name = null;
  }
}
