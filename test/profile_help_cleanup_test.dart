import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/features/profile/profile_help_page.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/theme/tokens.dart';

void main() {
  for (final lang in UiLang.values) {
    for (final width in [320.0, 390.0]) {
      testWidgets('help cleanup and outlined categories ${lang.name} $width', (t) async {
        t.view.physicalSize = Size(width, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final app = AppState(lang: lang);
        await t.pumpWidget(ChangeNotifierProvider.value(value: app,
          child: MaterialApp(theme: SurgoTheme.build(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(width == 320 ? 1.3 : 1)),
              child: child!),
            home: const Scaffold(body: ProfileHelpPage()))));
        await t.pumpAndSettle();
        expect(find.byType(ChoiceChip), findsNWidgets(4));
        void checkSelection(String selected) {
          for (final id in ['content', 'technical', 'idea', 'other']) {
            final chip = t.widget<ChoiceChip>(find.byKey(ValueKey('profile-feedback-category-$id')));
            expect(chip.showCheckmark, false);
            expect(chip.selected, id == selected);
            expect(chip.side!.color, id == selected ? SurgoColors.yellow : SurgoColors.line);
            expect(chip.side!.width, id == selected ? 1.5 : 1);
          }
        }
        checkSelection('content');
        final other = find.byKey(const ValueKey('profile-feedback-category-other'));
        await t.ensureVisible(other); await t.pumpAndSettle();
        await t.tap(other); await t.pumpAndSettle();
        checkSelection('other');
        final input = find.byKey(const ValueKey('profile-feedback-text'));
        await t.ensureVisible(input); await t.pumpAndSettle();
        await t.enterText(input, 'Feedback draft'); await t.pumpAndSettle();
        final preview = t.widget<SelectableText>(find.byType(SelectableText));
        expect(preview.data, contains('Feedback draft'));
        expect(preview.data, contains(lang == UiLang.zh ? '其他' : 'Other'));
        expect(preview.data, contains(lang == UiLang.zh ? '未发送' : 'NOT SENT'));
        expect(find.byKey(const ValueKey('profile-feedback-copy')), findsNothing);
        expect(find.text('复制反馈文案'), findsNothing);
        expect(find.text('Copy feedback'), findsNothing);
        expect(find.text('关于 SURGO'), findsNothing);
        expect(find.text('About SURGO'), findsNothing);
        expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
        expect(find.textContaining('仅复制，不会发送。'), findsNothing);
        expect(find.textContaining('Add a description to copy it'), findsNothing);
        expect(app.session, isEmpty);
        expect(t.takeException(), isNull);
      });
    }
  }
}
