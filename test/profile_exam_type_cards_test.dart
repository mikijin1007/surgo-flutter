import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/features/profile/profile_exam_type_cards.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/theme/tokens.dart';

void main() {
  for (final zh in [true, false]) {
    for (final width in [320.0, 390.0]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('exam tiles zh=$zh width=$width scale=$scale', (t) async {
          t.view.physicalSize = Size(width, 844);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          var selected = ExamType.ielts;
          await t.pumpWidget(MaterialApp(
              theme: SurgoTheme.build(),
              home: MediaQuery(
                  data: MediaQueryData(
                      size: Size(width, 844),
                      textScaler: TextScaler.linear(scale)),
                  child: Scaffold(
                      body: StatefulBuilder(
                          builder: (context, setState) => Padding(
                              padding: const EdgeInsets.all(38),
                              child: ProfileExamTypeCards(
                                  selected: selected,
                                  zh: zh,
                                  onChanged: (value) =>
                                      setState(() => selected = value))))))));
          await t.pumpAndSettle();
          Finder tile(String name) =>
              find.byKey(ValueKey('profile-exam-$name'));
          final left = t.getRect(tile('ielts'));
          final right = t.getRect(tile('toefl'));
          expect(left.size, right.size);
          expect(left.top, right.top);
          expect(right.left - left.right, 12);
          expect(left.left, 38);
          expect(right.right, width - 38);
          expect(left.height, greaterThanOrEqualTo(140));
          expect(find.byType(ChoiceChip), findsNothing);
          expect(t.widget<Semantics>(tile('ielts')).properties.checked, isTrue);
          expect(
              t
                  .widget<Material>(
                      find.byKey(const ValueKey('profile-exam-ielts-surface')))
                  .color,
              SurgoColors.yellow);
          await t.tap(tile('toefl'));
          await t.pumpAndSettle();
          expect(selected, ExamType.toefl);
          expect(t.widget<Semantics>(tile('toefl')).properties.checked, isTrue);
          expect(
              t.widget<Semantics>(tile('ielts')).properties.checked, isFalse);
          expect(
              t
                  .widget<Material>(
                      find.byKey(const ValueKey('profile-exam-toefl-surface')))
                  .color,
              SurgoColors.yellow);
          expect(
              t
                  .widget<Material>(
                      find.byKey(const ValueKey('profile-exam-ielts-surface')))
                  .color,
              Colors.white);
          expect(t.takeException(), isNull);
        });
      }
    }
  }
}
