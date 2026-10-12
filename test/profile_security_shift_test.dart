import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/app/shell.dart';
import 'package:surgo_flutter/features/profile/profile_security_page.dart';
import 'package:surgo_flutter/features/profile/profile_reference_ui.dart';
import 'package:surgo_flutter/features/profile/profile_style.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/widgets/phone_frame.dart';

void main() {
  setUpAll(() async { await Translator.load(); await QuestionBank.load(); });
  for (final lang in UiLang.values) {
    for (final width in [320.0, 390.0]) {
      testWidgets('security content shifts 20px without moving status bar ${lang.name} $width', (t) async {
        t.view.physicalSize = Size(width, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final app = AppState(current: SurgoPage.prep, lang: lang);
        Future<void> mount(Widget home) async {
          await t.pumpWidget(ChangeNotifierProvider.value(value: app,
            child: MaterialApp(key: UniqueKey(), theme: SurgoTheme.build(), home: home)));
          await t.pumpAndSettle();
        }
        Map<String, Rect> bounds() => {
          for (final key in ['profile-security-back', 'profile-security-avatar',
            'profile-security-password', 'profile-security-email'])
            key: t.getRect(find.byKey(ValueKey(key))),
          'section': t.getRect(find.byType(ProfileReferenceSection).first),
          'group': t.getRect(find.byType(ProfileReferenceGroup).first),
        };
        // Unshifted baseline: the previous 52px route inset, same page/style.
        await mount(const Scaffold(body: Stack(children: [
          Positioned.fill(top: 52, child: ProfileSecurityPage()),
          Positioned(top: 0, left: 0, right: 0, child: PhoneStatusBar()),
          Positioned(top: 0, left: 0, right: 0, child: PhoneNotch()),
        ])));
        final before = bounds();
        // The retained invisible slot gives the original, unshifted back
        // location; only the live overlay button moves down within the page.
        before['profile-security-back'] = t.getRect(find.descendant(
          of: find.byType(ProfileSettingsHeader), matching: find.byType(IconButton)).first);
        final statusBefore = t.getRect(find.byType(PhoneStatusBar));
        await mount(const SurgoShell());
        final entry = find.byKey(const ValueKey('profile-账号安全'));
        await t.ensureVisible(entry); await t.tap(entry); await t.pumpAndSettle();
        final after = bounds();
        for (final key in before.keys) {
          expect(after[key]!.left, before[key]!.left);
          expect(after[key]!.size, before[key]!.size);
          expect(after[key]!.top, closeTo(before[key]!.top - (key == 'profile-security-back' ? 0 : 20), .01), reason: key);
        }
        expect(t.getRect(find.byType(PhoneStatusBar)), statusBefore);
        final backRect = t.getRect(find.byKey(const ValueKey('profile-security-back')));
        // This part of the moved target overlaps the list's vertical band.
        // It must remain clickable, not be clipped by the old header bounds.
        await t.tapAt(Offset(backRect.center.dx, backRect.bottom - 4));
        await t.pumpAndSettle();
        expect(find.byKey(const ValueKey('profile-security-page')), findsNothing);
        expect(app.session, isEmpty);
        expect(t.takeException(), isNull);
      });
    }
  }
}
