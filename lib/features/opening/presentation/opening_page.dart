import 'dart:async';
import 'dart:math' as math;

import 'package:bicho_a_bicho/features/animals/domain/animal_catalog.dart';
import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';

class OpeningPage extends StatefulWidget {
  const OpeningPage({super.key, required this.onComplete, this.onSkipped});
  final VoidCallback onComplete;
  final VoidCallback? onSkipped;
  @override
  State<OpeningPage> createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _openingDuration = Duration(seconds: 5);
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _openingDuration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed && _reduced == false) {
            _complete();
          }
        });
  Timer? _timer;
  bool? _reduced;
  bool _completed = false;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced == reduced) return;
    _reduced = reduced;
    _timer?.cancel();
    if (reduced) {
      _controller.stop();
      _waitWithoutMotion();
    } else {
      _controller.forward();
    }
  }

  void _waitWithoutMotion() {
    _timer = Timer(_openingDuration, _complete);
  }

  void _complete() {
    if (!mounted || _completed || !_foreground) return;
    _completed = true;
    _timer?.cancel();
    _controller.stop();
    widget.onComplete();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) {
      _controller.stop(canceled: false);
      _timer?.cancel();
    } else if (!_completed) {
      if (_reduced == true) {
        _waitWithoutMotion();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: SafeArea(
      top: false,
      minimum: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TextButton.icon(
        onPressed: () {
          widget.onSkipped?.call();
          _complete();
        },
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(context.l10n.startNow),
      ),
    ),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pets_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.appWordmark,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(context.l10n.openingWelcome, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < 420 ? 3 : 4;
                    final size =
                        ((constraints.maxWidth - (columns - 1) * 16) / columns)
                            .clamp(60.0, 125.0);
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 20,
                      children: [
                        for (var i = 0; i < animals.length; i++)
                          AnimatedBuilder(
                            animation: _controller,
                            child: RepaintBoundary(
                              child: AnimalPicture(
                                path: animals[i].image,
                                label: animals[i].name,
                                size: size,
                              ),
                            ),
                            builder: (context, child) {
                              final t = _controller.value;
                              final entrance = _reduced == true
                                  ? 1.0
                                  : Curves.easeOutCubic.transform(
                                      ((t -
                                                  i /
                                                      math.max(
                                                        1,
                                                        animals.length - 1,
                                                      ) *
                                                      0.42) /
                                              0.32)
                                          .clamp(0, 1),
                                    );
                              final wave = _reduced == true
                                  ? 0.0
                                  : math.sin((t * 2 - i * 0.15) * math.pi * 2) *
                                        7 *
                                        entrance *
                                        (1 - t);
                              return Opacity(
                                opacity: entrance,
                                child: Transform.translate(
                                  offset: Offset(
                                    (i.isEven ? -20 : 20) * (1 - entrance),
                                    28 * (1 - entrance) + wave,
                                  ),
                                  child: Transform.scale(
                                    scale: 0.85 + entrance * 0.15,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(context.l10n.appTagline, textAlign: TextAlign.center),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
