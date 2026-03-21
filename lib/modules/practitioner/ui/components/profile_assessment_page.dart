import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/modules/practitioner/models/submodality_profile.dart';
import 'package:apparence_kit/modules/practitioner/providers/models/practitioner_state.dart';
import 'package:apparence_kit/modules/practitioner/providers/profile_assessment_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileAssessmentPage extends ConsumerStatefulWidget {
  final ProfileType profileType;

  const ProfileAssessmentPage({super.key, required this.profileType});

  @override
  ConsumerState<ProfileAssessmentPage> createState() =>
      _ProfileAssessmentPageState();
}

class _ProfileAssessmentPageState
    extends ConsumerState<ProfileAssessmentPage> {
  final _bodyLocationController = TextEditingController();
  int _intensitySlider = 5;

  @override
  void dispose() {
    _bodyLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      profileAssessmentNotifierProvider(profileType: widget.profileType),
    );
    final isPositive = widget.profileType == ProfileType.positive;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isPositive
              ? 'Positive Profile'
              : 'Negative Profile',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 6,
                      backgroundColor:
                          context.colors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPositive
                        ? 'Think of something you absolutely LOVE. How does your brain represent it?'
                        : 'Think of something you absolutely HATE or find disgusting. How does your brain code it?',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onBackground.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Question
            Expanded(
              child: state.isComplete
                  ? _buildComplete(context)
                  : _buildQuestion(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplete(BuildContext context) {
    final notifier = ref.read(
      profileAssessmentNotifierProvider(profileType: widget.profileType)
          .notifier,
    );
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            'Profile Complete!',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.profileType == ProfileType.positive
                ? 'Your positive neural signature has been mapped.'
                : 'Your negative neural signature has been mapped.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onBackground.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () async {
                await notifier.saveProfile();
                if (context.mounted) {
                  if (widget.profileType == ProfileType.positive) {
                    context.push('/practitioner/profile/negative');
                  } else {
                    context.go('/');
                  }
                }
              },
              child: Text(
                widget.profileType == ProfileType.positive
                    ? 'Next: Negative Profile'
                    : 'Finish',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(
    BuildContext context,
    ProfileAssessmentState state,
  ) {
    final questions = _getQuestions(context);
    if (state.currentQuestionIndex >= questions.length) {
      return _buildComplete(context);
    }
    final question = questions[state.currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.section,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ...question.options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      option.onSelect();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(option.label, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              )),
          if (question.isSlider) ...[
            Text(
              '$_intensitySlider',
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Slider(
              value: _intensitySlider.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) =>
                  setState(() => _intensitySlider = v.round()),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  question.onSliderSubmit?.call(_intensitySlider);
                },
                child: const Text('Confirm'),
              ),
            ),
          ],
          if (question.isTextInput) ...[
            TextField(
              controller: _bodyLocationController,
              decoration: InputDecoration(
                hintText: 'e.g., chest, stomach, throat, head...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_bodyLocationController.text.isNotEmpty) {
                    question.onTextSubmit
                        ?.call(_bodyLocationController.text);
                    _bodyLocationController.clear();
                  }
                },
                child: const Text('Confirm'),
              ),
            ),
          ],
          const Spacer(),
          if (state.currentQuestionIndex > 0)
            TextButton.icon(
              onPressed: () {
                ref
                    .read(profileAssessmentNotifierProvider(
                            profileType: widget.profileType)
                        .notifier)
                    .goBack();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<_Question> _getQuestions(BuildContext context) {
    final notifier = ref.read(
      profileAssessmentNotifierProvider(profileType: widget.profileType)
          .notifier,
    );
    return [
      // Visual modalities
      _Question(
        section: 'VISUAL',
        question: 'Is the image bright or dark?',
        options: [
          _Option('Bright', () => notifier.answerBrightness(ModalityBrightness.bright)),
          _Option('Dark', () => notifier.answerBrightness(ModalityBrightness.dark)),
          _Option('Neutral', () => notifier.answerBrightness(ModalityBrightness.neutral)),
        ],
      ),
      _Question(
        section: 'VISUAL',
        question: 'Is it in full color or black and white?',
        options: [
          _Option('Full color', () => notifier.answerColorType(ColorType.color)),
          _Option('Black & white', () => notifier.answerColorType(ColorType.blackAndWhite)),
          _Option('Muted/washed out', () => notifier.answerColorType(ColorType.muted)),
        ],
      ),
      _Question(
        section: 'VISUAL',
        question: 'Does it feel close to you or far away?',
        options: [
          _Option('Close/near', () => notifier.answerDistance(Distance.near)),
          _Option('Far away', () => notifier.answerDistance(Distance.far)),
          _Option('Medium distance', () => notifier.answerDistance(Distance.medium)),
        ],
      ),
      _Question(
        section: 'VISUAL',
        question: 'Is the image large or small?',
        options: [
          _Option('Large/life-size', () => notifier.answerSize(ModalitySize.large)),
          _Option('Small', () => notifier.answerSize(ModalitySize.small)),
          _Option('Medium', () => notifier.answerSize(ModalitySize.medium)),
        ],
      ),
      _Question(
        section: 'VISUAL',
        question: 'Is the image moving or still?',
        options: [
          _Option('Moving (like a movie)', () => notifier.answerMotion(Motion.moving)),
          _Option('Still (like a photo)', () => notifier.answerMotion(Motion.still)),
        ],
      ),
      _Question(
        section: 'VISUAL',
        question: 'Is it sharp and focused or fuzzy?',
        options: [
          _Option('Sharp/focused', () => notifier.answerFocus(Focus.sharp)),
          _Option('Fuzzy/blurry', () => notifier.answerFocus(Focus.fuzzy)),
        ],
      ),
      _Question(
        section: 'VISUAL',
        question: 'Is it framed (like watching a TV) or panoramic (wraparound)?',
        options: [
          _Option('Framed/bordered', () => notifier.answerFraming(Framing.framed)),
          _Option('Panoramic/surrounding', () => notifier.answerFraming(Framing.panoramic)),
        ],
      ),
      _Question(
        section: 'VISUAL',
        question: 'Does it feel flat or 3D?',
        options: [
          _Option('Flat/2D', () => notifier.answerDimensionality(Dimensionality.twoD)),
          _Option('3D/depth', () => notifier.answerDimensionality(Dimensionality.threeD)),
        ],
      ),
      // Auditory modalities
      _Question(
        section: 'AUDITORY',
        question: 'Are the sounds loud or soft?',
        options: [
          _Option('Loud', () => notifier.answerVolume(Volume.loud)),
          _Option('Soft/quiet', () => notifier.answerVolume(Volume.soft)),
          _Option('Medium', () => notifier.answerVolume(Volume.medium)),
        ],
      ),
      _Question(
        section: 'AUDITORY',
        question: 'Whose voice do you hear?',
        options: [
          _Option('My own voice', () => notifier.answerVoiceSource(VoiceSource.ownVoice)),
          _Option("Someone else's voice", () => notifier.answerVoiceSource(VoiceSource.otherVoice)),
          _Option('No voice', () => notifier.answerVoiceSource(VoiceSource.noVoice)),
        ],
      ),
      _Question(
        section: 'AUDITORY',
        question: 'Where does the sound come from?',
        options: [
          _Option('Left side', () => notifier.answerSoundDirection(SoundDirection.left)),
          _Option('Right side', () => notifier.answerSoundDirection(SoundDirection.right)),
          _Option('All around (surround)', () => notifier.answerSoundDirection(SoundDirection.surround)),
          _Option('Behind me', () => notifier.answerSoundDirection(SoundDirection.behind)),
        ],
      ),
      _Question(
        section: 'AUDITORY',
        question: 'Is the rhythm/tempo fast or slow?',
        options: [
          _Option('Fast', () => notifier.answerTempo(Tempo.fast)),
          _Option('Slow', () => notifier.answerTempo(Tempo.slow)),
          _Option('Medium', () => notifier.answerTempo(Tempo.medium)),
        ],
      ),
      _Question(
        section: 'AUDITORY',
        question: 'Is the pitch high or low?',
        options: [
          _Option('High pitch', () => notifier.answerPitch(Pitch.high)),
          _Option('Low pitch', () => notifier.answerPitch(Pitch.low)),
          _Option('Medium', () => notifier.answerPitch(Pitch.medium)),
        ],
      ),
      _Question(
        section: 'AUDITORY',
        question: 'Is the sound clear or muffled?',
        options: [
          _Option('Clear', () => notifier.answerClarity(Clarity.clear)),
          _Option('Muffled', () => notifier.answerClarity(Clarity.muffled)),
        ],
      ),
      // Kinesthetic modalities
      _Question(
        section: 'KINESTHETIC',
        question: 'Does the feeling feel heavy or light?',
        options: [
          _Option('Heavy', () => notifier.answerWeight(Weight.heavy)),
          _Option('Light', () => notifier.answerWeight(Weight.light)),
          _Option('Neutral', () => notifier.answerWeight(Weight.neutral)),
        ],
      ),
      _Question(
        section: 'KINESTHETIC',
        question: 'Is the sensation warm or cold?',
        options: [
          _Option('Warm', () => notifier.answerTemperature(Temperature.warm)),
          _Option('Cold', () => notifier.answerTemperature(Temperature.cold)),
          _Option('Neutral', () => notifier.answerTemperature(Temperature.neutral)),
        ],
      ),
      _Question(
        section: 'KINESTHETIC',
        question: 'Where in your body do you feel it most?',
        isTextInput: true,
        onTextSubmit: (value) => notifier.answerBodyLocation(value),
        options: [],
      ),
      _Question(
        section: 'KINESTHETIC',
        question: 'How intense is the feeling? (0-10)',
        isSlider: true,
        onSliderSubmit: (value) => notifier.answerIntensity(value),
        options: [],
      ),
      _Question(
        section: 'KINESTHETIC',
        question: 'Is it a pressure sensation or a tingle?',
        options: [
          _Option('Pressure', () => notifier.answerPressure(Pressure.pressure)),
          _Option('Tingle', () => notifier.answerPressure(Pressure.tingle)),
          _Option('Neutral/neither', () => notifier.answerPressure(Pressure.neutral)),
        ],
      ),
      _Question(
        section: 'KINESTHETIC',
        question: 'Is the body sensation moving or still?',
        options: [
          _Option('Moving/spreading', () => notifier.answerBodyMotion(Motion.moving)),
          _Option('Still/localized', () => notifier.answerBodyMotion(Motion.still)),
        ],
      ),
      // Perspective
      _Question(
        section: 'PERSPECTIVE',
        question: 'Are you IN the scene (first person) or watching from outside (third person)?',
        options: [
          _Option('In it (associated)', () => notifier.answerPerspective(Perspective.associated)),
          _Option('Watching from outside (dissociated)', () => notifier.answerPerspective(Perspective.dissociated)),
        ],
      ),
    ];
  }
}

class _Question {
  final String section;
  final String question;
  final List<_Option> options;
  final bool isSlider;
  final bool isTextInput;
  final void Function(int)? onSliderSubmit;
  final void Function(String)? onTextSubmit;

  _Question({
    required this.section,
    required this.question,
    required this.options,
    this.isSlider = false,
    this.isTextInput = false,
    this.onSliderSubmit,
    this.onTextSubmit,
  });
}

class _Option {
  final String label;
  final VoidCallback onSelect;

  _Option(this.label, this.onSelect);
}

