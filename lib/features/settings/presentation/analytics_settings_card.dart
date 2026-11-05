import 'package:flutter/material.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/widgets/soft_card.dart';

class AnalyticsSettingsCard extends StatelessWidget {
  const AnalyticsSettingsCard({super.key, required this.analytics});
  final AnalyticsController analytics;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: analytics,
    builder: (context, _) => SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados de uso opcionais',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Com autorização do responsável, o Google Analytics (GA4) pode receber telas visitadas, interações dos jogos e ajustes do app, junto com um identificador da instalação e informações do dispositivo. Esses dados ajudam a melhorar as brincadeiras.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Não enviamos nome, e-mail, senha, idade, diagnóstico, gravações ou transcrições. Não vinculamos a análise à conta do responsável. Publicidade personalizada e identificadores de publicidade estão desativados.',
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Compartilhar dados de uso'),
            value: analytics.consentGranted,
            onChanged: !analytics.supported || analytics.busy
                ? null
                : (enabled) async {
                    if (enabled) {
                      final agreed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          scrollable: true,
                          title: const Text('Autorizar dados de uso?'),
                          content: const Text(
                            'Esta escolha deve ser feita pelo responsável. Ao autorizar, você permite o envio dos dados de uso descritos nesta tela ao Google Analytics. A autorização é opcional e os jogos continuam funcionando se você recusar.\n\nVocê pode desativar depois. A desativação interrompe a coleta e redefine os dados locais do SDK; não apaga dados já enviados ao Google.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Não autorizar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sou responsável e autorizo'),
                            ),
                          ],
                        ),
                      );
                      if (agreed != true) return;
                    }
                    await analytics.setConsent(enabled);
                  },
          ),
          if (analytics.busy)
            const Text('Aplicando sua escolha…')
          else if (!analytics.supported)
            const Text('A análise ainda não está configurada nesta plataforma.')
          else if (analytics.status == AnalyticsStatus.failed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Não foi possível aplicar ou salvar a escolha. O envio de eventos do app está suspenso. Tente novamente antes de fechar o aplicativo.',
                ),
                TextButton(
                  onPressed: () =>
                      analytics.setConsent(analytics.consentGranted),
                  child: const Text('Tentar novamente'),
                ),
              ],
            )
          else
            Text(
              analytics.enabled
                  ? 'Coleta autorizada neste dispositivo. Você pode desativar a qualquer momento.'
                  : 'Coleta desativada. Todas as brincadeiras continuam disponíveis.',
            ),
        ],
      ),
    ),
  );
}
