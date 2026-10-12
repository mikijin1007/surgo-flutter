import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/features/profile/profile_security_page.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/theme/tokens.dart';

void main() {
  Future<AppState> mount(WidgetTester t, UiLang lang, double width, double scale) async {
    t.view.physicalSize = Size(width, width == 320 ? 568 : 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final app = AppState(current: SurgoPage.prep, lang: lang);
    app.session['keep'] = 'saved-learning-data';
    await t.pumpWidget(ChangeNotifierProvider.value(value: app,
      child: MaterialApp(theme: SurgoTheme.build(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!),
        home: const Scaffold(body: ProfileSecurityPage()))));
    await t.pumpAndSettle();
    return app;
  }

  for (final lang in UiLang.values) {
    for (final width in [320.0, 390.0]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('deletion dialog centered and safe ${lang.name} $width $scale', (t) async {
          final app = await mount(t, lang, width, scale);
          final entry = find.byKey(const ValueKey('profile-security-delete-account'));
          await t.scrollUntilVisible(entry, 160,
              scrollable: find.byType(Scrollable).first);
          await t.pumpAndSettle();
          await t.tap(entry); await t.pumpAndSettle();
          final dialog = find.byKey(const ValueKey('profile-security-delete-account-dialog'));
          expect(dialog, findsOneWidget);
          final title = find.descendant(of: dialog,
              matching: find.text(lang == UiLang.zh ? '注销账号' : 'Delete account'));
          expect(t.widget<Text>(title).textAlign, TextAlign.center);
          expect(find.descendant(of: dialog, matching: find.textContaining(
              lang == UiLang.zh ? '仅供说明 ·' : 'Information only ·')), findsNothing);
          expect(find.descendant(of: dialog, matching: find.byWidgetPredicate((w) =>
              w is Container && w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).color == SurgoColors.yellowTint)), findsNothing);
          final confirm = find.byKey(const ValueKey('profile-security-delete-confirm'));
          final close = find.byKey(const ValueKey('profile-security-detail-close'));
          final row = find.byKey(const ValueKey('profile-security-delete-actions'));
          final a = t.getRect(confirm), b = t.getRect(close), r = t.getRect(row);
          expect(a.top, closeTo(b.top, .01));
          expect(b.left - a.right, closeTo(12, .01));
          expect(a.height, greaterThanOrEqualTo(48));
          expect(b.height, greaterThanOrEqualTo(48));
          expect(r.center.dx, closeTo(t.getRect(dialog).center.dx, .01));
          expect(t.getRect(title).center.dx, closeTo(r.center.dx, .01));
          expect(find.text(lang == UiLang.zh ? '确定注销账号' : 'Confirm deletion'), findsOneWidget);
          expect(find.text(lang == UiLang.zh ? '关闭' : 'Close'), findsOneWidget);
          await t.tap(confirm); await t.pumpAndSettle();
          expect(find.byKey(const ValueKey('profile-security-delete-unavailable')), findsOneWidget);
          expect(dialog, findsOneWidget);
          expect(app.session, {'keep': 'saved-learning-data'});
          expect(app.current, SurgoPage.prep);
          await t.tap(close); await t.pumpAndSettle();
          expect(dialog, findsNothing);
          expect(find.byKey(const ValueKey('profile-security-page')), findsOneWidget);
          expect(app.session, {'keep': 'saved-learning-data'});
          expect(t.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('other security dialogs retain their original banner and close action', (t) async {
    await mount(t, UiLang.zh, 390, 1);
    await t.tap(find.byKey(const ValueKey('profile-security-password')));
    await t.pumpAndSettle();
    expect(find.text('仅供说明 · 真实账号服务未接入'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-security-delete-confirm')), findsNothing);
    expect(find.byKey(const ValueKey('profile-security-detail-close')), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
