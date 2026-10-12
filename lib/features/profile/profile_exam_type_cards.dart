import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../theme/tokens.dart';

/// Two equal selection tiles. Only the chosen draft exam changes on tap;
/// persistence remains the responsibility of the parent form's Save action.
class ProfileExamTypeCards extends StatelessWidget {
  const ProfileExamTypeCards(
      {super.key,
      required this.selected,
      required this.zh,
      required this.onChanged});

  final ExamType selected;
  final bool zh;
  final ValueChanged<ExamType> onChanged;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final type in ExamType.values) ...[
            if (type == ExamType.toefl) const SizedBox(width: 12),
            Expanded(
                child: _ExamTypeTile(
                    type: type,
                    selected: selected == type,
                    zh: zh,
                    onSelect: () => onChanged(type))),
          ],
        ]),
      );
}

class _ExamTypeTile extends StatelessWidget {
  const _ExamTypeTile(
      {required this.type,
      required this.selected,
      required this.zh,
      required this.onSelect});
  final ExamType type;
  final bool selected, zh;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final subtitle = type == ExamType.ielts
        ? (zh ? '雅思备考' : 'IELTS prep')
        : (zh ? '托福备考' : 'TOEFL prep');
    const activeInk = Color(0xFF3A2E00);
    final ink = selected ? activeInk : SurgoColors.ink;
    return Semantics(
      key: ValueKey('profile-exam-${type.name}'),
      label: '${type.label}, $subtitle',
      button: true,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      onTap: onSelect,
      child: ExcludeSemantics(
          child: Material(
        key: ValueKey('profile-exam-${type.name}-surface'),
        color: selected ? SurgoColors.yellow : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
                color: selected ? SurgoColors.yellow : SurgoColors.line,
                width: 1.2)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelect,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 140),
            child: Stack(children: [
              Positioned(
                  right: -18,
                  bottom: -16,
                  child: IgnorePointer(
                      child: Icon(
                    type == ExamType.ielts
                        ? Icons.school_outlined
                        : Icons.computer_outlined,
                    size: 102,
                    color: (selected ? activeInk : SurgoColors.muted)
                        .withValues(alpha: .10),
                  ))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label,
                        style: TextStyle(
                            fontFamily: SurgoFontFamily.heading,
                            fontFamilyFallback: SurgoFontFamily.fallback,
                            fontSize: 22,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: ink)),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: TextStyle(
                            fontFamily: SurgoFontFamily.body,
                            fontFamilyFallback: SurgoFontFamily.fallback,
                            fontSize: 12,
                            height: 1.3,
                            color: selected
                                ? activeInk.withValues(alpha: .7)
                                : SurgoColors.muted)),
                    const SizedBox(height: 24),
                    Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? activeInk : Colors.transparent,
                            border: selected
                                ? null
                                : Border.all(
                                    color:
                                        SurgoColors.muted.withValues(alpha: .4),
                                    width: 1.5)),
                        child: selected
                            ? const Icon(Icons.check,
                                size: 15, color: Colors.white)
                            : null),
                  ],
                ),
              ),
            ]),
          ),
        ),
      )),
    );
  }
}
