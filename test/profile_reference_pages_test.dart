import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/app/shell.dart';
import 'package:surgo_flutter/features/profile/profile_about_page.dart';
import 'package:surgo_flutter/features/profile/profile_reference_ui.dart';
import 'package:surgo_flutter/theme/app_theme.dart';

void main() {
  testWidgets('reference row status and chevron align to right edge', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 320, child: ProfileReferenceGroup(children: [
        ProfileReferenceRow(label: '账号', value: '未接入', onTap: _noop),
      ]))))));
    final chevron = t.getRect(find.byIcon(Icons.chevron_right));
    expect(chevron.right, 302);
    expect(t.takeException(), isNull);
  });

  setUpAll(() async {
    await Translator.load();
    await QuestionBank.load();
  });
  test('about package version matches pubspec, not a made-up release', () {
    final spec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'version: ([^+\s]+)\+(\d+)').firstMatch(spec)!;
    expect(ProfileAboutPage.packageVersion, '${match[1]} (${match[2]})');
  });
  Future<AppState> mount(WidgetTester t, UiLang lang, double width) async {
    t.view.physicalSize = Size(width, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final app = AppState(current: SurgoPage.prep, lang: lang);
    await t.pumpWidget(ChangeNotifierProvider.value(
        value: app,
        child:
            MaterialApp(theme: SurgoTheme.build(), home: const SurgoShell())));
    await t.pumpAndSettle();
    return app;
  }

  Future<void> tap(WidgetTester t, String key) async {
    final f = find.byKey(ValueKey(key));
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  for (final lang in UiLang.values) {
    for (final width in [320.0, 390.0]) {
      testWidgets('reference settings zh=${lang.name} width=$width', (t) async {
        final app = await mount(t, lang, width);
        for (final e in {
          '账号安全': 'security',
          '语言设置': 'language',
          '帮助与支持': 'help',
          '关于 SURGO': 'about'
        }.entries) {
          await tap(t, 'profile-${e.key}');
          expect(
              find.byKey(ValueKey('profile-${e.value}-page')), findsOneWidget);
          final material = find.byWidgetPredicate((w) =>
              w is Material && w.color == ProfileReferenceColors.background);
          expect(material, findsWidgets);
          expect(t.takeException(), isNull);
          if (e.value == 'about') {
            expect(find.byKey(const ValueKey('profile-about-logo')),
                findsOneWidget);
            expect(find.byKey(const ValueKey('profile-about-version-label')),
                findsOneWidget);
            for (final id in [
              'intro',
              'terms',
              'privacy',
              'privacy-summary',
              'capabilities',
              'version'
            ]) {
              await tap(t, 'profile-about-$id');
              expect(find.byKey(const ValueKey('profile-about-dialog')),
                  findsOneWidget);
              expect(t.takeException(), isNull);
              await tap(t, 'profile-about-close');
            }
          }
          await tap(t, 'profile-${e.value}-back');
        }
        expect(app.session, isEmpty);
      });
    }
  }
  testWidgets(
      'language picker closes on selection, cancels without changing state',
      (t) async {
    final app = await mount(t, UiLang.zh, 390);
    await tap(t, 'profile-语言设置');
    await tap(t, 'profile-language-picker');
    await tap(t, 'profile-language-en');
    expect(app.lang, UiLang.en);
    expect(find.byType(RadioListTile<UiLang>), findsNothing);
    await tap(t, 'profile-language-picker');
    await t.tapAt(const Offset(10, 200));
    await t.pumpAndSettle();
    expect(app.lang, UiLang.en);
    expect(app.session, isEmpty);
    expect(t.takeException(), isNull);
  });
}

void _noop() {}
