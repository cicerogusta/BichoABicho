import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/soft_card.dart';
import '../../settings/presentation/app_settings.dart';
import '../../animals/domain/animal.dart';
import 'profile_appearance.dart';

class ProfileNamePage extends StatefulWidget {
  const ProfileNamePage({
    super.key,
    required this.settings,
    this.profile,
    this.enterAfterSave = true,
  });
  final AppSettings settings;
  final int? profile;
  final bool enterAfterSave;
  @override
  State<ProfileNamePage> createState() => _ProfileNamePageState();
}

class _ProfileNamePageState extends State<ProfileNamePage> {
  final _form = GlobalKey<FormState>();
  late int? _savedProfile = widget.profile;
  late String _animalId = widget.profile == null
      ? animals.first.id
      : widget.settings.profile(widget.profile!).animalId;
  late final TextEditingController _name = TextEditingController(
    text: widget.profile == null
        ? ''
        : widget.settings.profile(widget.profile!).name,
  );
  bool _saving = false;
  String? _error;

  Future<void> _save({bool withoutName = false}) async {
    if (_saving || (!withoutName && !_form.currentState!.validate())) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final name = withoutName ? '' : _name.text;
    if (_savedProfile == null) {
      _savedProfile = await widget.settings.createProfile(
        animalId: _animalId,
        name: name,
      );
    } else {
      await widget.settings.updateProfile(
        _savedProfile!,
        name: name,
        animalId: _animalId,
      );
    }
    if (!mounted) return;
    if (widget.settings.storageFailed) {
      setState(() {
        _saving = false;
        _error = 'Não foi possível salvar neste aparelho. Tente novamente.';
      });
      return;
    }
    Navigator.of(context).pop(_savedProfile);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animal = animals.firstWhere((animal) => animal.id == _animalId);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.profile == null ? 'Novo cartão' : 'Seu cartão'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SoftCard(
                        color: profileColor(_animalId),
                        child: Column(
                          children: [
                            AnimalPicture(
                              path: animal.image,
                              label: animal.name,
                              size: 100,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Seu cartão do ${animal.name.toLowerCase()}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Escolha seu bichinho',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final option in animals)
                            ChoiceChip(
                              label: Text(option.name),
                              avatar: AnimalPicture(
                                path: option.image,
                                label: '',
                                size: 32,
                                decorative: true,
                              ),
                              selected: _animalId == option.id,
                              onSelected: _saving
                                  ? null
                                  : (_) =>
                                        setState(() => _animalId = option.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Como vamos chamar você?',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Um responsável pode ajudar a escrever. O nome aparecerá neste cartão e no acompanhamento das brincadeiras.',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _name,
                        enabled: !_saving,
                        maxLength: 24,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Nome ou apelido (opcional)',
                          hintText: 'Ex.: Ana',
                          helperText: 'Pode ser só o primeiro nome.',
                        ),
                        onFieldSubmitted: (_) => unawaited(_save()),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Salvo somente neste aparelho. Não é necessário criar uma conta.',
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Semantics(liveRegion: true, child: Text(_error!)),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _saving ? null : () => unawaited(_save()),
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(
                          _saving
                              ? 'Salvando...'
                              : widget.enterAfterSave
                              ? 'Salvar e brincar'
                              : 'Salvar cartão',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => unawaited(_save(withoutName: true)),
                        child: Text(
                          widget.enterAfterSave
                              ? 'Continuar sem nome'
                              : 'Usar só o bichinho',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
