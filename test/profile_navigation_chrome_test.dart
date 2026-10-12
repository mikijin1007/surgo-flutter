import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/app/shell.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/widgets/bottom_nav.dart';

void main() {
  setUpAll(() async { await Translator.load(); await QuestionBank.load(); });
  for (final lang in UiLang.values) {
    for (final exam in ExamType.values) {
      testWidgets('profile has no bottom bar and plain back ${lang.name} ${exam.name}', (t) async {
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final app = AppState(current: SurgoPage.prep, lang: lang, examType: exam);
        await t.pumpWidget(ChangeNotifierProvider.value(value: app,
          child: MaterialApp(theme: SurgoTheme.build(), home: const SurgoShell())));
        await t.pumpAndSettle();
        expect(find.byType(BottomNav), findsNothing);
        final back = find.byKey(const ValueKey('profile-back'));
        expect(t.getSize(back), const Size(40, 40));
        final button = t.widget<IconButton>(back);
        final icon = button.icon as Icon;
        expect(icon.icon, Icons.arrow_back);
        expect(icon.size, 24);
        expect(button.style!.backgroundColor!.resolve({}), Colors.transparent);
        expect(button.style!.overlayColor!.resolve({WidgetState.pressed}), Colors.transparent);
        expect(find.descendant(of: back, matching: find.byType(DecoratedBox)), findsNothing);
        final scroll = t.widget<SingleChildScrollView>(find.byKey(const ValueKey('profile-scroll')));
        expect(scroll.padding, const EdgeInsets.fromLTRB(18, 8, 18, 30));
        expect(t.getSize(find.byKey(const ValueKey('profile-avatar'))), const Size(104, 104));
        await t.tap(back); await t.pumpAndSettle();
        expect(app.current, SurgoPage.ielts);
        expect(app.examType, exam);
        expect(find.byType(BottomNav), findsOneWidget);
        app.go(SurgoPage.report); await t.pumpAndSettle();
        expect(find.byType(BottomNav), findsOneWidget);
        app.go(SurgoPage.prep); await t.pumpAndSettle();
        expect(find.byType(BottomNav), findsNothing);
        final logout = find.byKey(const ValueKey('profile-logout'));
        await t.ensureVisible(logout); await t.pumpAndSettle();
        final rect = t.getRect(logout);
        expect(rect.bottom, lessThanOrEqualTo(844));
        expect(t.takeException(), isNull);
      });
    }
  }
}
