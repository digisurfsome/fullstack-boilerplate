import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/modules/practitioner/models/practitioner_session.dart';
import 'package:apparence_kit/modules/practitioner/models/technique.dart';
import 'package:apparence_kit/modules/practitioner/repositories/technique_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'technique_detail_page.g.dart';

@riverpod
Future<Technique?> techniqueDetail(Ref ref, String id) {
  final repo = ref.read(techniqueRepositoryProvider);
  return repo.getById(id);
}

class TechniqueDetailPage extends ConsumerStatefulWidget {
  final String techniqueId;

  const TechniqueDetailPage({super.key, required this.techniqueId});

  @override
  ConsumerState<TechniqueDetailPage> createState() =>
      _TechniqueDetailPageState();
}

class _TechniqueDetailPageState extends ConsumerState<TechniqueDetailPage> {
  final _targetController = TextEditingController();
  final _outcomeController = TextEditingController();
  TargetCategory _selectedCategory = TargetCategory.custom;

  @override
  void dispose() {
    _targetController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  void _startSession() {
    if (_targetController.text.isEmpty || _outcomeController.text.isEmpty) {
      return;
    }
    context.push(
      '/practitioner/session'
      '?techniqueId=${widget.techniqueId}'
      '&category=${_selectedCategory.name}'
      '&target=${Uri.encodeComponent(_targetController.text)}'
      '&outcome=${Uri.encodeComponent(_outcomeController.text)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final techniqueAsync =
        ref.watch(techniqueDetailProvider(widget.techniqueId));
    return techniqueAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(child: Text('Error: $error')),
      ),
      data: (technique) {
        if (technique == null) {
          return Scaffold(
            backgroundColor: context.colors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Center(child: Text('Technique not found')),
          );
        }
        return _buildContent(context, technique);
      },
    );
  }

  Widget _buildContent(BuildContext context, Technique technique) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(technique.name),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              technique.description,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onBackground.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 16,
                    color:
                        context.colors.onBackground.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text(
                  '${technique.durationMinutes} minutes',
                  style: context.textTheme.bodySmall?.copyWith(
                    color:
                        context.colors.onBackground.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${technique.protocol.length} steps',
                  style: context.textTheme.bodySmall?.copyWith(
                    color:
                        context.colors.onBackground.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Set Up Your Session',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Category', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TargetCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat.name),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                  selectedColor:
                      context.colors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.onBackground,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('What do you want to work on?',
                style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              key: const Key('target_input'),
              controller: _targetController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the specific issue or goal...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('What is your desired outcome?',
                style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              key: const Key('outcome_input'),
              controller: _outcomeController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe what success looks like...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _startSession,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Begin Session',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
