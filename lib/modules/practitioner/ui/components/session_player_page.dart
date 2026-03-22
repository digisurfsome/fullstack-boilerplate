import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/modules/practitioner/models/practitioner_session.dart';
import 'package:apparence_kit/modules/practitioner/models/technique.dart';
import 'package:apparence_kit/modules/practitioner/providers/models/practitioner_state.dart';
import 'package:apparence_kit/modules/practitioner/providers/session_player_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SessionPlayerPage extends ConsumerStatefulWidget {
  final String techniqueId;
  final String targetCategory;
  final String targetDescription;
  final String desiredOutcome;

  const SessionPlayerPage({
    super.key,
    required this.techniqueId,
    required this.targetCategory,
    required this.targetDescription,
    required this.desiredOutcome,
  });

  @override
  ConsumerState<SessionPlayerPage> createState() => _SessionPlayerPageState();
}

class _SessionPlayerPageState extends ConsumerState<SessionPlayerPage> {
  final _inputController = TextEditingController();
  int _sliderValue = 5;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(
      sessionPlayerNotifierProvider(
        techniqueId: widget.techniqueId,
        targetCategory: widget.targetCategory,
        targetDescription: widget.targetDescription,
        desiredOutcome: widget.desiredOutcome,
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showExitDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: stateAsync.when(
            data: (state) => _buildSession(context, state),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ),
      ),
    );
  }

  Widget _buildSession(BuildContext context, SessionPlayerState state) {
    final step = state.currentStep;
    final isTimedStep = step.durationSeconds > 0;
    return Column(
      children: [
        // Top bar with progress
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _showExitDialog(context),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 6,
                    backgroundColor:
                        context.colors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${state.currentStepIndex + 1}/${state.technique.protocol.length}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onBackground.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        // Phase indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  step.phase.toUpperCase(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  step.instruction,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onBackground.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Step-type specific content
                _buildStepContent(context, state, step),
                const Spacer(),
                // Timer display
                if (isTimedStep) _buildTimer(context, state, step),
              ],
            ),
          ),
        ),
        // Navigation buttons
        _buildNavigation(context, state),
      ],
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    SessionPlayerState state,
    ProtocolStep step,
  ) {
    switch (step.type) {
      case 'input':
        return TextField(
          controller: _inputController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your response...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      case 'intensity_rating':
        return Column(
          children: [
            Text(
              '$_sliderValue',
              style: context.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: _intensityColor(_sliderValue),
              ),
            ),
            Slider(
              value: _sliderValue.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: '$_sliderValue',
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _sliderValue = value.round());
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('None',
                    style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onBackground
                            .withValues(alpha: 0.4))),
                Text('Maximum',
                    style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onBackground
                            .withValues(alpha: 0.4))),
              ],
            ),
          ],
        );
      case 'category_select':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TargetCategory.values
              .map((cat) => ChoiceChip(
                    label: Text(cat.name),
                    selected: state.stepResponses['category'] == cat.name,
                    onSelected: (_) {
                      _notifier.recordResponse('category', cat.name);
                    },
                  ))
              .toList(),
        );
      case 'tapping_point':
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.touch_app,
                  size: 48,
                  color: context.colors.primary),
              const SizedBox(height: 8),
              Text(
                _tappingPointLabel(step.point ?? ''),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTimer(
    BuildContext context,
    SessionPlayerState state,
    ProtocolStep step,
  ) {
    final remaining = step.durationSeconds - state.elapsedSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return Column(
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w300,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: state.elapsedSeconds / step.durationSeconds,
            minHeight: 4,
            backgroundColor: context.colors.primary.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(height: 12),
        if (!state.isTimerRunning)
          TextButton.icon(
            onPressed: () => _notifier.startTimer(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Timer'),
          )
        else
          TextButton.icon(
            onPressed: () => _notifier.stopTimer(),
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
          ),
      ],
    );
  }

  Widget _buildNavigation(BuildContext context, SessionPlayerState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          if (!state.isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _notifier.previousStep(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (!state.isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                // Save input responses
                if (_inputController.text.isNotEmpty) {
                  _notifier.recordResponse(
                    'step_${state.currentStepIndex}',
                    _inputController.text,
                  );
                  _inputController.clear();
                }
                // Save intensity
                if (state.currentStep.type == 'intensity_rating') {
                  _notifier.recordResponse(
                    'intensity_${state.currentPhaseName}',
                    _sliderValue,
                  );
                  await _notifier.recordIntensity(_sliderValue);
                }
                if (state.isLastStep) {
                  await _notifier.completeSession();
                  if (context.mounted) {
                    _showCompletionDialog(context);
                  }
                } else {
                  await _notifier.nextStep();
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                state.isLastStep ? 'Complete' : 'Next',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SessionPlayerNotifier get _notifier => ref.read(
        sessionPlayerNotifierProvider(
          techniqueId: widget.techniqueId,
          targetCategory: widget.targetCategory,
          targetDescription: widget.targetDescription,
          desiredOutcome: widget.desiredOutcome,
        ).notifier,
      );

  Color _intensityColor(int value) {
    if (value <= 3) return Colors.green;
    if (value <= 6) return Colors.orange;
    return Colors.red;
  }

  static const _tappingPointLabels = {
    'eyebrow': 'Eyebrow Point',
    'side_of_eye': 'Side of Eye',
    'under_eye': 'Under Eye',
    'under_nose': 'Under Nose',
    'chin': 'Chin Point',
    'collarbone': 'Collarbone',
    'under_arm': 'Under Arm',
    'top_of_head': 'Top of Head',
  };

  String _tappingPointLabel(String point) =>
      _tappingPointLabels[point] ?? point;

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
          'Your progress will be saved but the session will be marked as abandoned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              _notifier.abandonSession();
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Complete'),
        content: const Text(
          'Great work! Your session has been recorded. Consistent practice deepens the neural pathways.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
