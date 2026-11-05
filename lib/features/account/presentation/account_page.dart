import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/soft_card.dart';
import 'account_view_model.dart';
import '../../../core/analytics/usage_analytics.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.viewModel,
    this.analytics = const NoopUsageAnalytics(),
  });
  final AccountViewModel viewModel;
  final UsageAnalytics analytics;
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountViewModel _model;
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  @override
  void initState() {
    super.initState();
    _model = widget.viewModel;
    unawaited(_model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    unawaited(
      _model.submit(
        email: _email.text,
        password: _password.text,
        registrationName: _register ? _name.text : null,
      ),
    );
    _password.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Conta do responsável')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListenableBuilder(
            listenable: _model,
            builder: (context, _) => SoftCard(
              child: _model.name != null
                  ? Column(
                      children: [
                        Text(
                          'Olá, ${_model.name}!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sua conta está conectada. O histórico de brincadeiras fica somente neste dispositivo.',
                        ),
                        if (_model.error != null) Text(_model.error!),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.insights_outlined),
                          label: const Text('Voltar aos responsáveis'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _model.busy
                              ? null
                              : () => unawaited(_model.signOut()),
                          child: const Text('Sair da conta'),
                        ),
                      ],
                    )
                  : Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _register ? 'Criar conta' : 'Bem-vindo de volta',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'A conta é opcional. Todas as brincadeiras funcionam sem cadastro.',
                          ),
                          const SizedBox(height: 24),
                          if (_register) ...[
                            TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(
                                labelText: 'Nome do responsável',
                              ),
                              validator: (value) =>
                                  (value?.trim().isEmpty ?? true)
                                  ? 'Informe seu nome.'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                            ),
                            validator: (value) =>
                                value != null &&
                                    RegExp(
                                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                    ).hasMatch(value.trim())
                                ? null
                                : 'Informe um e-mail válido.',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Informe sua senha.'
                                : _register && value.length < 8
                                ? 'Use pelo menos 8 caracteres.'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          if (_model.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(_model.error!),
                              ),
                            ),
                          FilledButton(
                            onPressed: _model.busy ? null : _submit,
                            child: Text(
                              _model.busy
                                  ? 'Aguarde…'
                                  : _register
                                  ? 'Criar conta'
                                  : 'Entrar',
                            ),
                          ),
                          TextButton(
                            onPressed: _model.busy
                                ? null
                                : () => setState(() {
                                    _register = !_register;
                                    widget.analytics.screen(
                                      _register
                                          ? UsageScreen.accountRegister
                                          : UsageScreen.accountLogin,
                                    );
                                    _password.clear();
                                    _form.currentState?.reset();
                                  }),
                            child: Text(
                              _register
                                  ? 'Já tenho uma conta'
                                  : 'Quero criar uma conta',
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
