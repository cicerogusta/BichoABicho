import 'dart:async';

import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/analytics/usage_analytics.dart';
import '../../../core/widgets/soft_card.dart';
import 'account_message_text.dart';
import 'account_view_model.dart';

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
    appBar: AppBar(title: Text(context.l10n.accountTitle)),
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
                          context.l10n.accountGreeting(
                            _model.name!.isEmpty
                                ? context.l10n.guardian
                                : _model.name!,
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(context.l10n.accountConnected),
                        if (_model.error != null)
                          Text(_model.error!.resolve(context)),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.insights_outlined),
                          label: Text(context.l10n.backToParents),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _model.busy
                              ? null
                              : () => unawaited(_model.signOut()),
                          child: Text(context.l10n.signOut),
                        ),
                      ],
                    )
                  : Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _register
                                ? context.l10n.createAccount
                                : context.l10n.accountWelcome,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(context.l10n.accountOptional),
                          const SizedBox(height: 24),
                          if (_register) ...[
                            TextFormField(
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: context.l10n.guardianName,
                              ),
                              validator: (value) =>
                                  (value?.trim().isEmpty ?? true)
                                  ? context.l10n.enterGuardianName
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              labelText: context.l10n.email,
                            ),
                            validator: (value) =>
                                value != null &&
                                    RegExp(
                                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                    ).hasMatch(value.trim())
                                ? null
                                : context.l10n.enterValidEmail,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              labelText: context.l10n.password,
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? context.l10n.enterPassword
                                : _register && value.length < 8
                                ? context.l10n.minimumPasswordLength
                                : null,
                          ),
                          const SizedBox(height: 20),
                          if (_model.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(_model.error!.resolve(context)),
                              ),
                            ),
                          FilledButton(
                            onPressed: _model.busy ? null : _submit,
                            child: Text(
                              _model.busy
                                  ? 'Aguarde…'
                                  : _register
                                  ? context.l10n.createAccount
                                  : context.l10n.signIn,
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
                                  ? context.l10n.alreadyHaveAccount
                                  : context.l10n.wantCreateAccount,
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
