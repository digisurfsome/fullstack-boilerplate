import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/modules/practitioner/providers/practitioner_home_notifier.dart';
import 'package:apparence_kit/modules/practitioner/ui/widgets/profile_status_card.dart';
import 'package:apparence_kit/modules/practitioner/ui/widgets/session_history_card.dart';
import 'package:apparence_kit/modules/practitioner/ui/widgets/technique_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PractitionerHomePage extends ConsumerWidget {
  const PractitionerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practitionerHomeNotifierProvider);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: state.when(
          data: (data) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'Practitioner',
                    style: context.textTheme.headlineLarge,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'NLP, EFT & Visualization Sessions',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colors.onBackground.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              // Modality Profile Status
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ProfileStatusCard(
                    hasCompletedProfiling: data.hasCompletedProfiling,
                    profilingProgress: data.profilingProgress,
                    onStartProfiling: () =>
                        context.push('/practitioner/profile/positive'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Techniques Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Text(
                    'Techniques',
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ),
              if (data.techniques.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'No techniques available yet.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onBackground.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: data.techniques.length,
                  itemBuilder: (context, index) {
                    final technique = data.techniques[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TechniqueCard(
                        technique: technique,
                        onTap: () => context.push(
                          '/practitioner/technique/${technique.id}',
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Recent Sessions
              if (data.recentSessions.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Sessions',
                          style: context.textTheme.titleLarge,
                        ),
                        Text(
                          '${data.completedSessionCount} completed',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onBackground
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList.separated(
                  itemCount:
                      data.recentSessions.length > 5 ? 5 : data.recentSessions.length,
                  itemBuilder: (context, index) {
                    final session = data.recentSessions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SessionHistoryCard(session: session),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
