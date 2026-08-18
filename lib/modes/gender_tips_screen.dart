import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../models/gender_rule.dart';
import '../theme/app_theme.dart';
import '../widgets/quiz_shell.dart';
import 'gender_quiz_screen.dart';

enum _RuleFilter { all, ending, semantic }

/// Mazo navegable de reglas de género — el "por qué" del quiz, en forma de
/// micro-lecciones (docs/PLAN.md §4, §6.5). No es quiz: no hay respuesta,
/// solo consulta + un atajo a practicarla.
class GenderTipsScreen extends StatefulWidget {
  const GenderTipsScreen({super.key});

  @override
  State<GenderTipsScreen> createState() => _GenderTipsScreenState();
}

class _GenderTipsScreenState extends State<GenderTipsScreen> {
  List<GenderRule>? _rules;
  _RuleFilter _filter = _RuleFilter.all;
  final _pageController = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    DataRepository.loadGenderRules().then((rules) {
      if (mounted) setState(() => _rules = rules);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<GenderRule> get _filtered {
    final rules = _rules ?? const <GenderRule>[];
    return switch (_filter) {
      _RuleFilter.all => rules,
      _RuleFilter.ending => rules.where((r) => r.kind == RuleKind.ending).toList(),
      _RuleFilter.semantic => rules.where((r) => r.kind == RuleKind.semantic).toList(),
    };
  }

  void _setFilter(_RuleFilter filter) {
    setState(() {
      _filter = filter;
      _page = 0;
    });
    if (_pageController.hasClients) _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_rules == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final rules = _filtered;
    return Scaffold(
      body: QuizShell(
        index: _page,
        total: rules.length,
        onClose: () => Navigator.of(context).pop(),
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: rules.isEmpty
                  ? Center(
                      child: Text(
                        'Sin reglas en este filtro',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: rules.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: _RuleCard(rule: rules[i]),
                          ),
                        ),
                        Positioned(
                          left: 4,
                          child: _NavArrow(
                            icon: Icons.chevron_left_rounded,
                            onTap: _page > 0
                                ? () => _pageController.previousPage(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                    )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          child: _NavArrow(
                            icon: Icons.chevron_right_rounded,
                            onTap: _page < rules.length - 1
                                ? () => _pageController.nextPage(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                    )
                                : null,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          _FilterChip(
            label: 'Todas',
            selected: _filter == _RuleFilter.all,
            onTap: () => _setFilter(_RuleFilter.all),
          ),
          _FilterChip(
            label: 'Terminaciones',
            selected: _filter == _RuleFilter.ending,
            onTap: () => _setFilter(_RuleFilter.ending),
          ),
          _FilterChip(
            label: 'Semánticas',
            selected: _filter == _RuleFilter.semantic,
            onTap: () => _setFilter(_RuleFilter.semantic),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: kPrimaryContainer,
      backgroundColor: kSurfaceContainer,
      labelStyle: TextStyle(color: selected ? kOnPrimaryContainer : kOnSurfaceVariant),
      side: const BorderSide(color: kOutline),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: onTap == null ? kOutline : kOnSurfaceVariant,
      onPressed: onTap,
    );
  }
}

class _RuleCard extends StatelessWidget {
  final GenderRule rule;

  const _RuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    final accent = colorForGender(rule.gender);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kOutline),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 50,
            spreadRadius: -12,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(999)),
              child: Text(
                rule.gender.name,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: kOnPrimary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            Text(rule.pattern, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 30)),
            const SizedBox(height: 12),
            Text(rule.explanation, style: Theme.of(context).textTheme.bodyLarge),
            if (rule.examples.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final example in rule.examples)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(example, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
            ],
            if (rule.exceptions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: const Border(left: BorderSide(color: kError, width: 3)),
                  color: kError.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Excepción: ${rule.exceptions.join(', ')}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: kOnSurface),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GenderQuizScreen(ruleId: rule.id)),
                ),
                child: const Text('⚡ Prueba esto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
