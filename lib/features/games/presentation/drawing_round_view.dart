import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../domain/drawing_template.dart';
import 'drawing_controller.dart';
import 'game_view_model.dart';
import 'widgets/animal_celebration.dart';

class DrawingRoundView extends StatelessWidget {
  const DrawingRoundView({
    super.key,
    required this.model,
    required this.onAdvance,
  });
  final GameViewModel model;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final drawing = model.drawing!;
    final animal = model.round.animal;
    final template = drawingTemplates[animal.id]!;
    final correct = model.feedback == RoundFeedback.correct;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Descoberta ${model.index + 1} de ${model.session.rounds.length}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Vamos desenhar ${animal.name.toLowerCase()}?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Observe o modelo. Desenhe o contorno com o dedo e toque em “Conferir desenho”.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SoftCard(
          color: AppColors.sage,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Semantics(
                image: true,
                label: 'Modelo do contorno de ${animal.name.toLowerCase()}',
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: AnimalOutlinePainter(template: template),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Um traço parecido já vale. Olhos e detalhes não são obrigatórios.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (correct) ...[
          AnimalCelebration(key: ValueKey(model.index), animal: animal),
          Text(
            'Você descobriu!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Seu desenho ficou parecido com o modelo!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label:
                    'Área de desenho de ${animal.name.toLowerCase()}. Desenhe deslizando um dedo. Pode pedir ajuda ou pular.',
                child: _DrawingCanvas(
                  template: template,
                  drawing: drawing,
                  enabled: !correct,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!correct)
          ListenableBuilder(
            listenable: drawing,
            builder: (context, _) => Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: drawing.hasInk ? drawing.undo : null,
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('Desfazer'),
                    ),
                    OutlinedButton.icon(
                      onPressed: drawing.hasInk ? drawing.clear : null,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Limpar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        model.showHint();
                        drawing.showGuide(!drawing.guide);
                      },
                      icon: const Icon(Icons.lightbulb_outline_rounded),
                      label: Text(
                        drawing.guide ? 'Ocultar contorno' : 'Quero uma dica',
                      ),
                    ),
                  ],
                ),
                if (drawing.full)
                  const Text(
                    'O quadro está cheio de traços. Você pode desfazer ou limpar.',
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: drawing.hasInk ? model.checkDrawing : null,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Conferir desenho'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Column(
            children: [
              if (model.feedback == RoundFeedback.retry)
                const Text(
                  'Vamos aproximar o contorno do modelo? Acrescente ou ajuste os traços. A dica pode ajudar.',
                  textAlign: TextAlign.center,
                ),
              if (model.mediaMessage != null)
                Text(model.mediaMessage!, textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (correct)
          FilledButton.icon(
            onPressed: onAdvance,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              model.index == model.session.rounds.length - 1
                  ? 'Concluir brincadeira'
                  : 'Próxima descoberta',
            ),
          )
        else
          TextButton(
            onPressed: onAdvance,
            child: const Text('Pular por enquanto'),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DrawingCanvas extends StatefulWidget {
  const _DrawingCanvas({
    required this.template,
    required this.drawing,
    required this.enabled,
  });
  final DrawingTemplate template;
  final DrawingController drawing;
  final bool enabled;
  @override
  State<_DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<_DrawingCanvas> {
  int? _pointer;
  void _end(int pointer) {
    if (_pointer != pointer) return;
    widget.drawing.end();
    _pointer = null;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      Point<double> point(Offset offset) => Point(
        offset.dx / constraints.maxWidth,
        offset.dy / constraints.maxHeight,
      );
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: RawGestureDetector(
            key: const ValueKey('drawing_board'),
            behavior: HitTestBehavior.opaque,
            gestures: {
              if (widget.enabled)
                EagerGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      EagerGestureRecognizer
                    >(EagerGestureRecognizer.new, (_) {}),
            },
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: widget.enabled
                  ? (event) {
                      if (_pointer != null ||
                          event.buttons & kPrimaryButton == 0) {
                        return;
                      }
                      _pointer = event.pointer;
                      widget.drawing.begin(point(event.localPosition));
                    }
                  : null,
              onPointerMove: widget.enabled
                  ? (event) {
                      if (_pointer == event.pointer) {
                        widget.drawing.append(point(event.localPosition));
                      }
                    }
                  : null,
              onPointerUp: (event) => _end(event.pointer),
              onPointerCancel: (event) => _end(event.pointer),
              child: CustomPaint(
                painter: AnimalOutlinePainter(
                  template: widget.template,
                  drawing: widget.drawing,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class AnimalOutlinePainter extends CustomPainter {
  AnimalOutlinePainter({required this.template, this.drawing})
    : super(repaint: drawing);
  final DrawingTemplate template;
  final DrawingController? drawing;

  Path _path(Iterable<Point<double>> points, Size size) {
    final path = Path();
    var first = true;
    for (final point in points) {
      if (first) {
        path.moveTo(point.x * size.width, point.y * size.height);
        first = false;
      } else {
        path.lineTo(point.x * size.width, point.y * size.height);
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final outline = _path(template.contour, size);
    if (drawing == null) {
      canvas.drawPath(outline, Paint()..color = AppColors.yellow);
      canvas.drawPath(
        outline,
        ink
          ..color = AppColors.primary
          ..strokeWidth = 2.5,
      );
      for (final eye in template.eyes) {
        canvas.drawCircle(
          Offset(eye.x * size.width, eye.y * size.height),
          size.width * .015,
          Paint()..color = AppColors.ink,
        );
      }
      return;
    }
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(1),
        const Radius.circular(24),
      ),
      ink
        ..color = AppColors.border
        ..strokeWidth = 2,
    );
    if (drawing!.guide) {
      for (final metric in outline.computeMetrics()) {
        for (var distance = 0.0; distance < metric.length; distance += 16) {
          canvas.drawPath(
            metric.extractPath(distance, min(distance + 9, metric.length)),
            ink
              ..color = AppColors.muted.withValues(alpha: .5)
              ..strokeWidth = 4,
          );
        }
      }
    }
    for (final stroke in drawing!.paths) {
      ink
        ..color = AppColors.primary
        ..strokeWidth = 5;
      if (stroke.length == 1) {
        final point = stroke.first;
        canvas.drawCircle(
          Offset(point.x * size.width, point.y * size.height),
          2.5,
          Paint()..color = AppColors.primary,
        );
      } else {
        canvas.drawPath(_path(stroke, size), ink);
      }
    }
  }

  @override
  bool shouldRepaint(AnimalOutlinePainter oldDelegate) =>
      oldDelegate.template != template || oldDelegate.drawing != drawing;
}
