import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../games/domain/game_definition.dart';
import 'app_settings.dart';
import 'analytics_settings_card.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/analytics/usage_analytics.dart';
import '../../progress/presentation/learning_report.dart';
import '../../progress/presentation/profile_settings_card.dart';

class ParentPage extends StatelessWidget {
  const ParentPage({
    super.key,
    required this.settings,
    required this.accountBuilder,
    this.analytics,
  });
  final AppSettings settings;
  final WidgetBuilder accountBuilder;
  final AnalyticsController? analytics;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Cada criança tem seu ritmo.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Ajuste a experiência junto com a criança. Observe o conforto, os interesses e as formas de comunicação que ela prefere.',
            ),
            const SizedBox(height: 24),
            ProfileSettingsCard(settings: settings),
            const SizedBox(height: 24),
            LearningReport(settings: settings),
            const SizedBox(height: 24),
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: settings.soundEnabled,
                    onChanged: (value) =>
                        unawaited(settings.update(sound: value)),
                    title: const Text('Sons e comemorações'),
                    subtitle: const Text(
                      'Sons ao tocar e uma música curta ao acertar. Sem música de fundo.',
                    ),
                  ),
                  SwitchListTile.adaptive(
                    value: settings.calmMode,
                    onChanged: (value) =>
                        unawaited(settings.update(calm: value)),
                    title: const Text('Movimento reduzido'),
                    subtitle: const Text(
                      'Reduz transições. A preferência do sistema também é respeitada.',
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opções por descoberta',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            for (final n in [2, 3])
                              ChoiceChip(
                                label: Text('$n opções'),
                                selected: settings.choiceCount == n,
                                onSelected: (_) =>
                                    unawaited(settings.update(choices: n)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tamanho da brincadeira',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            for (final n in [4, 6])
                              ChoiceChip(
                                label: Text('$n descobertas'),
                                selected: settings.rounds == n,
                                onSelected: (_) => unawaited(
                                  settings.update(sessionRounds: n),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'As mudanças valem para a próxima brincadeira.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (settings.storageFailed)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Não foi possível salvar neste dispositivo. As mudanças atuais continuam disponíveis enquanto o app estiver aberto.',
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Nosso caminho de descobertas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Brincadeiras concluídas neste dispositivo. Este registro não mede desenvolvimento nem desempenho.',
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                children: [
                  for (final game in games)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.pets_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(game.title)),
                          Text(
                            '${settings.completed(game.kind.name)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _reset(context),
                child: const Text('Apagar histórico local'),
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              color: AppColors.sage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brincar com intenção',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Associação, exploração de sons, expressão e pequenas quantidades dialogam com os campos de experiência da Educação Infantil na BNCC. As letras são uma exploração lúdica, sem exigir alfabetização.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Não há cronômetro, perda de pontos ou exigência de fala. Ofereça ajuda sem pressionar. Respeite pausas e o desejo de parar.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Para brincar de Detetive dos bichos, leia a pista e compare as imagens junto com a criança. Em Histórias da turma, leia as duas cenas e a pergunta; a história fica disponível para consultar. A criança pode tocar ou indicar uma imagem para você selecionar. Não é preciso saber ler.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Essas duas propostas foram adaptadas de atividades de adivinhação e contação com figuras reunidas pela Secretaria de Educação de Santa Catarina. As narrativas e ilustrações do app são próprias. Experimente também com livros e brinquedos fora da tela, respeitando os interesses da criança.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'O app é um recurso educativo complementar. A adequação das atividades deve ser avaliada com a família e a equipe pedagógica. Não faz avaliação clínica.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Privacidade e conta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (analytics != null) ...[
              const SizedBox(height: 16),
              AnalyticsSettingsCard(analytics: analytics!),
            ],
            const SizedBox(height: 12),
            const Text(
              'Os jogos não precisam de conta ou internet. O histórico fica neste dispositivo. O compartilhamento opcional de eventos de uso está descrito nos ajustes de dados acima. Não é necessário informar nome ou idade da criança. Os apelidos opcionais dos cartões ficam neste aparelho.\n\nO microfone só é solicitado no botão “Quero falar”. O serviço de reconhecimento do sistema pode enviar áudio ao provedor do dispositivo e precisar de internet. O app não grava nem armazena esse áudio. Prefira responder por toque se não desejar usar o microfone.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  settings: RouteSettings(name: UsageScreen.accountLogin.name),
                  builder: accountBuilder,
                ),
              ),
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Conta opcional do responsável'),
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'Bicho a Bicho',
              ),
              icon: const Icon(Icons.info_outline),
              label: const Text('Licenças e créditos'),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Apagar o histórico?'),
        content: const Text(
          'As contagens de brincadeiras e o acompanhamento de todos os perfis deste dispositivo serão apagados. Os ajustes serão mantidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Manter histórico'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await settings.resetProgress();
  }
}
