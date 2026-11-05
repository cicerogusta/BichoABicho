import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../games/domain/game_definition.dart';
import '../../settings/presentation/app_settings.dart';
import '../domain/learning_history.dart';
import 'profile_selection_page.dart';
import '../../../core/analytics/usage_analytics.dart';

class LearningReport extends StatefulWidget {
  const LearningReport({super.key, required this.settings});
  final AppSettings settings;
  @override
  State<LearningReport> createState() => _LearningReportState();
}

class _LearningReportState extends State<LearningReport> {
  late int _reportProfile = widget.settings.activeProfile;
  GameKind? _game;
  int? _choices;

  Future<void> _chooseProfile() async {
    final profile = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        settings: RouteSettings(name: UsageScreen.reportProfileSelection.name),
        builder: (context) => ProfileSelectionPage(
          settings: widget.settings,
          allowBack: true,
          allowCreation: false,
          configureUnnamed: false,
          onSelected: (id) => Navigator.pop(context, id),
        ),
      ),
    );
    if (profile != null && mounted) setState(() => _reportProfile = profile);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.settings,
    builder: (context, _) {
      final settings = widget.settings;
      final history = settings.learningHistory;
      final total = history.summarize(
        _reportProfile,
        game: _game,
        choices: _choices,
      );
      final ranking = history.rankAnimals(
        _reportProfile,
        game: _game,
        choices: _choices,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Acompanhamento das brincadeiras',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Disponível sem login. Escolha abaixo de quem deseja consultar os registros. Consultar outro cartão não muda quem está brincando.',
          ),
          const SizedBox(height: 16),
          if (settings.storageFailed) ...[
            SoftCard(
              color: AppColors.peach,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Não foi possível ler ou salvar parte dos registros. Os dados desta sessão continuam disponíveis enquanto o app estiver aberto.',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => unawaited(settings.retrySave()),
                    child: const Text('Tentar salvar dados locais'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Acumulado desde o início do registro ou a última limpeza. A conta opcional não sincroniza estes dados.',
          ),
          const SizedBox(height: 16),
          SoftCard(
            color: AppColors.sage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'De quem é este relatório?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const ValueKey('report_profile_selector'),
                  onPressed: _chooseProfile,
                  icon: AnimalPicture(
                    path: settings.profile(_reportProfile).avatar.image,
                    label: '',
                    size: 32,
                    decorative: true,
                  ),
                  label: Text(
                    '${settings.profileLabel(_reportProfile)} • ${settings.profile(_reportProfile).cardNumber}',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Brincando agora: ${settings.profileLabel(settings.activeProfile)}. Para trocar quem brinca, use o cartão na tela inicial.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _filter(
            label: 'Atividade do relatório',
            value: _game?.name ?? 'all',
            items: {
              'all': 'Todas as atividades',
              for (final game in games) game.kind.name: game.title,
            },
            onChanged: (value) => setState(
              () =>
                  _game = value == 'all' ? null : GameKind.values.byName(value),
            ),
          ),
          const SizedBox(height: 12),
          _filter(
            label: 'Alternativas no momento da rodada',
            value: _choices?.toString() ?? 'all',
            items: const {
              'all': 'Todas as configurações',
              '2': '2 alternativas',
              '3': '3 alternativas',
              '0': 'Desenho sem alternativas',
            },
            onChanged: (value) =>
                setState(() => _choices = int.tryParse(value)),
          ),
          const SizedBox(height: 16),
          if (total.started == 0)
            const SoftCard(
              child: Text(
                'Ainda não há registros neste filtro. Abra uma brincadeira com este perfil para começar. O uso anterior à atualização não tinha registro de erros.',
              ),
            )
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 500 &&
                        MediaQuery.textScalerOf(context).scale(16) <= 24
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final metric in [
                      ('Tentativas incorretas', '${total.errors}'),
                      (
                        'Rodadas com erro',
                        '${total.roundsWithErrors} de ${total.answered} respondidas',
                      ),
                      ('Acertos na primeira tentativa', '${total.firstTry}'),
                      ('Rodadas com dica', '${total.hints}'),
                      ('Rodadas resolvidas', '${total.correct}'),
                      ('Rodadas puladas', '${total.skipped}'),
                    ])
                      SizedBox(
                        width: width,
                        child: SoftCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                metric.$2,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(metric.$1),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Rodadas abertas: ${total.started} • Com resposta: ${total.answered}. Rodadas interrompidas também ficam registradas.',
            ),
            const SizedBox(height: 24),
            Text(
              'Animais com maior proporção de rodadas com erro',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ordem pela proporção de rodadas respondidas que tiveram erro, com o tamanho da amostra ao lado. O animal é o alvo da pergunta, inclusive em letras, contagem e histórias.',
            ),
            const SizedBox(height: 12),
            if (ranking.isEmpty)
              const SoftCard(
                child: Text(
                  'Nenhuma tentativa incorreta registrada neste filtro.',
                ),
              ),
            for (final entry in ranking) ...[
              SoftCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimalPicture(
                      path: entry.animal.image,
                      label: '',
                      size: 56,
                      decorative: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.animal.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rodadas respondidas com erro: ${entry.stats.roundsWithErrors} de ${entry.stats.answered} (${(entry.stats.errorRate * 100).round()}%).',
                          ),
                          Text(
                            'Tentativas incorretas: ${entry.stats.errors} • Rodadas com dica: ${entry.stats.hints}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Text(
              'Por atividade',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final game in games.where(
              (g) => _game == null || g.kind == _game,
            ))
              _ActivitySummary(
                game: game,
                stats: history.summarize(
                  _reportProfile,
                  game: game.kind,
                  choices: _choices,
                ),
              ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Como ler: cada resposta incorreta conta como uma tentativa; uma rodada com vários erros conta uma vez em “Rodadas com erro”. Dicas não são erros. Acerto na primeira tentativa pode ter tido dica. Falhas do microfone, pausas e saltos não são erros. Uma amostra pequena ou ajuda de um adulto pode mudar a interpretação. Esses dados descrevem o uso do app e não medem desenvolvimento ou dificuldade clínica.',
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _clearProfile(context),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(
                'Apagar acompanhamento de ${settings.profileLabel(_reportProfile)}',
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _filter({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        items: [
          for (final entry in items.entries)
            DropdownMenuItem(
              value: entry.key,
              child: Text(
                entry.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    ),
  );

  Future<void> _clearProfile(BuildContext context) async {
    final profile = _reportProfile;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(
          'Apagar acompanhamento de ${widget.settings.profileLabel(profile)}?',
        ),
        content: const Text(
          'Apaga erros, acertos, dicas e rodadas deste perfil em todas as atividades e configurações. Os outros perfis e os ajustes serão preservados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar acompanhamento'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted && _reportProfile == profile) {
      await widget.settings.clearProfileHistory(profile: profile);
    }
  }
}

class _ActivitySummary extends StatelessWidget {
  const _ActivitySummary({required this.game, required this.stats});
  final GameDefinition game;
  final LearningStats stats;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(game.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            stats.started == 0
                ? 'Ainda sem registros.'
                : 'Tentativas incorretas: ${stats.errors} • Rodadas respondidas com erro: ${stats.roundsWithErrors} de ${stats.answered} • Acertos na primeira tentativa: ${stats.firstTry}',
          ),
        ],
      ),
    ),
  );
}
