import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/features/profile/profile_security_page.dart';
import 'package:surgo_flutter/features/profile/profile_style.dart';
import 'package:surgo_flutter/features/profile/profile_reference_ui.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/theme/tokens.dart';

void main() {
  test('profile text is semibold without changing size or line height', () {
    expect(profileBody.fontWeight, FontWeight.w600);
    expect(profileBody.fontSize, 14);
    expect(profileBody.height, 1.55);
    expect(profileHeading().fontSize, 20);
    expect(profileHeading().fontWeight, FontWeight.w800);
  });

  for (final lang in UiLang.values) {
    for (final width in [320.0, 390.0]) {
      testWidgets('clean security identity ${lang.name} $width', (t) async {
        t.view.physicalSize = Size(width, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final app = AppState(lang: lang);
        await t.pumpWidget(ChangeNotifierProvider.value(
          value: app,
          child: MaterialApp(
            theme: SurgoTheme.build(),
            home: const Scaffold(body: ProfileSecurityPage()),
          ),
        ));
        await t.pumpAndSettle();
        expect(find.textContaining('原型示例身份'), findsNothing);
        expect(find.textContaining('姓名与邮箱为演示资料'), findsNothing);
        expect(find.textContaining('Prototype example identity'), findsNothing);
        expect(find.textContaining('The name and email are demo data.'), findsNothing);
        expect(find.text('账号与安全'), findsNothing);
        expect(find.text('Account security'), findsNothing);
        expect(find.byKey(const ValueKey('profile-security-back')), findsOneWidget);
        expect(find.text('Miki Jin'), findsOneWidget);
        expect(find.text('miki.jin@example.com'), findsOneWidget);
        final avatar = find.byKey(const ValueKey('profile-security-avatar'));
        expect(t.getSize(avatar), const Size(48, 48));
        expect(t.widget<CircleAvatar>(avatar).backgroundColor, SurgoColors.yellowTint);
        expect(t.widget<CircleAvatar>(avatar).backgroundImage,
          const AssetImage('assets/images/profile_avatar_20261012.png'));
        expect(find.descendant(of: avatar, matching: find.byIcon(Icons.person_rounded)), findsNothing);
        expect(find.text('轻点各行查看说明，不会更改账号。'), findsNothing);
        expect(find.text('Tap a row for details. No account changes are made.'), findsNothing);
        expect(find.byType(ExpansionTile), findsNothing);
        for (final row in t.widgetList<ProfileReferenceRow>(find.byType(ProfileReferenceRow))) {
          expect(row.value, isNull);
        }
        expect(find.text(lang == UiLang.zh ? '注销账号' : 'Delete account'), findsOneWidget);
        expect(find.text('注销账号说明'), findsNothing);
        final sessions = find.byKey(const ValueKey('profile-security-sessions'));
        final sessionsText = t.widget<Text>(find.descendant(of: sessions, matching: find.byType(Text)).first);
        expect(sessionsText.maxLines, 1);
        expect(sessionsText.softWrap, false);
        final password = find.byKey(const ValueKey('profile-security-password'));
        final label = t.widget<Text>(find.descendant(of: password, matching: find.byType(Text)).first);
        expect(label.style?.fontWeight, FontWeight.w600);
        await t.tap(password);
        await t.pumpAndSettle();
        expect(find.text(lang == UiLang.zh
            ? '仅供说明 · 真实账号服务未接入'
            : 'Information only · no live account service'), findsOneWidget);
        await t.tap(find.byKey(const ValueKey('profile-security-detail-close')));
        await t.pumpAndSettle();
        final deletion = find.byKey(const ValueKey('profile-security-delete-account'));
        await t.ensureVisible(deletion); await t.tap(deletion); await t.pumpAndSettle();
        expect(find.byKey(const ValueKey('profile-security-delete-account-dialog')), findsOneWidget);
        expect(find.textContaining(lang == UiLang.zh
            ? '注销账号目前不可用' : 'Account deletion is unavailable'), findsOneWidget);
        expect(app.session, isEmpty);
        expect(t.takeException(), isNull);
      });
    }
  }
}
