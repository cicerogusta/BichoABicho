import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../animals/domain/animal.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/soft_card.dart';

/// A finite celebration: no flashing, infinite loops or navigation side effects.
class AnimalCelebration extends StatefulWidget {
  const AnimalCelebration({super.key, required this.animal});
  final Animal animal;
  @override
  State<AnimalCelebration> createState() => _AnimalCelebrationState();
}

class _AnimalCelebrationState extends State<AnimalCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool? _reduced;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced == reduced) return;
    _reduced = reduced;
    if (reduced) {
      _controller.stop();
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${widget.animal.name} comemorando seu acerto',
    image: true,
    child: ExcludeSemantics(
      child: SizedBox(
        width: double.infinity,
        height: 190,
        child: AnimatedBuilder(
          animation: _controller,
          child: RepaintBoundary(
            child: AnimalPicture(
              path: widget.animal.image,
              label: '',
              size: 160,
              decorative: true,
            ),
          ),
          builder: (context, child) {
            final t = _reduced == true ? 1.0 : _controller.value;
            final bounce = math.sin(t * math.pi * 4).abs() * (1 - t);
            return Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < 6; i++)
                  Positioned(
                    left: null,
                    child: Transform.translate(
                      offset: Offset(
                        math.cos(i * math.pi / 3) * (70 + t * 25),
                        math.sin(i * math.pi / 3) * (65 + t * 14),
                      ),
                      child: Opacity(
                        opacity: _reduced == true
                            ? 0.65
                            : (math.sin(math.pi * t) * 0.8).clamp(0, 1),
                        child: Icon(
                          i.isEven
                              ? Icons.star_rounded
                              : Icons.favorite_rounded,
                          size: i.isEven ? 20 : 14,
                          color: i.isEven
                              ? AppColors.primary
                              : const Color(0xFFB77849),
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(0, -18 * bounce),
                  child: Transform.rotate(
                    angle: math.sin(t * math.pi * 4) * 0.06 * (1 - t),
                    child: Transform.scale(
                      scale: 1 + bounce * 0.1,
                      child: child,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
