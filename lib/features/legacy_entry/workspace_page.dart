import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../app/routes.dart';
import '../../theme/tokens.dart';

/// The title, outside margins and footer match ExamSelectionPage. Only the
/// learning-mode module keeps its compact radio cards and Continue action.
/// Content can grow and scroll on small screens without covering the footer.
class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  static const background = SurgoColors.bg;
  static const ink = SurgoColors.ink;
  static const selectedColor = Color(0xFFF6C238);
  static const inactiveColor = Color(0xFFE4DED2);
  static const accentInk = Color(0xFF241D05);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final zh = app.lang == UiLang.zh;
    final titles = [
      zh ? '考试备考' : 'Exam Prep',
      zh ? '日常英语' : 'Everyday English'
    ];
    final descriptions = [
      zh
          ? '针对雅思、托福等标准化考试，按官方评分标准训练听说读写。'
          : 'Prepare for IELTS or TOEFL and train all four skills with official scoring criteria.',
      zh
          ? '在真实场景中练习口语与表达，提升日常沟通自信。'
          : 'Practise real-life speaking and build everyday confidence.',
    ];
    final statusText = zh ? '即将上线' : 'Coming soon';
    return ColoredBox(
      key: const ValueKey('workspace-page'),
      color: background,
      child: LayoutBuilder(builder: (context, bounds) {
        final cardHeight = _ModeOption.commonHeight(context,
            width: bounds.maxWidth - 76,
            titles: titles,
            descriptions: descriptions,
            status: statusText);
        return SingleChildScrollView(
          key: const ValueKey('workspace-scroll'),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: bounds.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                // Exam page: shell (18,8) + page (20,6).
                padding: const EdgeInsets.fromLTRB(38, 14, 38, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60, bottom: 22),
                      child: Column(children: [
                        Text(zh ? '你想怎么学？' : 'How would you like to learn?',
                            key: const ValueKey('workspace-heading'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontFamilyFallback: SurgoFontFamily.fallback,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.5,
                                color: ink)),
                        const SizedBox(height: 6),
                        Text(
                            zh
                                ? '选择一个学习空间，我们会为你定制学习路径。'
                                : 'Choose a learning space and we’ll tailor your learning path.',
                            key: const ValueKey('workspace-subtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11, color: SurgoColors.muted)),
                      ]),
                    ),
                    // Compensate for the heading moving down 20px; keep the first card fixed.
                    const SizedBox(height: 40),
                    _ModeOption(
                      optionKey: const ValueKey('workspace-exam'),
                      title: titles[0],
                      description: descriptions[0],
                      height: cardHeight,
                      selected: true,
                      // Selecting never skips the explicit Continue action.
                      onSelect: () {},
                    ),
                    const SizedBox(height: 28),
                    _ModeOption(
                      optionKey: const ValueKey('workspace-everyday'),
                      title: titles[1],
                      description: descriptions[1],
                      status: statusText,
                      height: cardHeight,
                      selected: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                          child: SizedBox(
                              width: 156,
                              height: 56,
                              child: FilledButton(
                                key: const ValueKey('workspace-continue'),
                                style: FilledButton.styleFrom(
                                    backgroundColor: accentInk,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(26)),
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: .4)),
                                onPressed: () => app.go(SurgoPage.exam),
                                child: Text(zh ? '继续' : 'CONTINUE'),
                              ))),
                    ),
                    const Spacer(),
                    Padding(
                      // Same 150px / 50% logo, 56px above the phone bottom.
                      padding: const EdgeInsets.only(top: 36, bottom: 56),
                      child: Opacity(
                          opacity: .5,
                          child: Center(
                              child: Image.asset('assets/images/surgo_logo.png',
                                  key: const ValueKey('workspace-logo'),
                                  width: 150,
                                  semanticLabel: 'SURGO'))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ModeOption extends StatelessWidget {
  static const titleStyle = TextStyle(
      fontFamily: 'Outfit',
      fontFamilyFallback: SurgoFontFamily.fallback,
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w800);
  static const descriptionStyle = TextStyle(fontSize: 13, height: 1.5);
  static const statusStyle =
      TextStyle(fontSize: 12, height: 1.3, color: Color(0xFF6A6256));

  // Use the taller content for BOTH cards, including translations/text scaling.
  // Measure using the same styles, inherited metrics and available text width.
  static double commonHeight(BuildContext context,
      {required double width,
      required List<String> titles,
      required List<String> descriptions,
      required String status}) {
    final textWidth = (width - 44 - 18 - 24).clamp(1.0, double.infinity);
    double measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(
            text: text, style: DefaultTextStyle.of(context).style.merge(style)),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: textWidth);
      final result = painter.height;
      painter.dispose();
      return result;
    }

    var result = 132.0;
    for (var i = 0; i < titles.length; i++) {
      final content = 36 +
          measure(titles[i], titleStyle) +
          7 +
          measure(descriptions[i], descriptionStyle) +
          (i == 1 ? 6 + measure(status, statusStyle) : 0);
      if (content > result) result = content;
    }
    return result.ceilToDouble();
  }

  const _ModeOption(
      {required this.optionKey,
      required this.title,
      required this.description,
      required this.selected,
      required this.height,
      this.status,
      this.onSelect});

  final Key optionKey;
  final String title;
  final String description;
  final String? status;
  final bool selected;
  final double height;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: optionKey,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: onSelect != null,
      child: Material(
        color: selected
            ? WorkspacePage.selectedColor
            : WorkspacePage.inactiveColor,
        elevation: selected ? 6 : 0,
        shadowColor: const Color(0x24000000),
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(26),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Row(children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: titleStyle.copyWith(
                            color: selected
                                ? WorkspacePage.accentInk
                                : const Color(0xFF3A352C))),
                    const SizedBox(height: 7),
                    Text(description,
                        style: descriptionStyle.copyWith(
                            color: selected
                                ? const Color(0xB83C2E00)
                                : const Color(0x993A352C))),
                    if (status != null) ...[
                      const SizedBox(height: 6),
                      Text(status!, style: statusStyle),
                    ],
                  ],
                )),
                const SizedBox(width: 18),
                ExcludeSemantics(
                    child: Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? WorkspacePage.accentInk
                                : const Color(0xFFBFB6A8)),
                        child: selected
                            ? const DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle))
                            : null)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
