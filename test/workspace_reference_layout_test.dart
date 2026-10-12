import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/app/shell.dart';
import 'package:surgo_flutter/features/legacy_entry/workspace_page.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/widgets/global_menu.dart';

void main() {
  setUpAll(() async {
    await Translator.load();
    await QuestionBank.load();
  });
  Future<AppState> mount(WidgetTester t, UiLang lang, Size size,
      {double textScale = 1}) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final app = AppState(
        current: SurgoPage.workspace, lang: lang, examType: ExamType.toefl);
    app.session['sentinel'] = 'keep';
    await t.pumpWidget(ChangeNotifierProvider.value(
        value: app,
        child: MaterialApp(
            theme: SurgoTheme.build(),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!),
            home: const SurgoShell())));
    await t.pumpAndSettle();
    return app;
  }

  Finder key(String value) => find.byKey(ValueKey(value));

  for (final lang in UiLang.values) {
    testWidgets('workspace reference ${lang.name}: layout and Continue gate',
        (t) async {
      final app = await mount(t, lang, const Size(390, 844));
      expect(t.takeException(), isNull);
      expect(
          find.descendant(
              of: find.byType(WorkspacePage), matching: find.byType(Image)),
          findsOneWidget); // Footer logo only; no option-card illustration.
      expect(key('workspace-back'), findsNothing);
      expect(key('workspace-cancel'), findsNothing);
      expect(key('global-消息通知'), findsOneWidget);
      expect(key('global-设置'), findsOneWidget);
      expect(t.getRect(key('workspace-exam')).width, 314);
      expect(t.getRect(key('workspace-exam')).left, 38);
      expect(t.getRect(key('workspace-exam')).size,
          t.getRect(key('workspace-everyday')).size);
      expect(t.getRect(key('workspace-everyday')).left, 38);
      // Heading moved down 20px, but the first card keeps its previous position.
      expect(t.getRect(key('workspace-exam')).top,
          t.getRect(key('workspace-subtitle')).bottom + 62);
      expect(t.getRect(key('workspace-everyday')).top,
          t.getRect(key('workspace-exam')).bottom + 28);
      expect(t.getRect(key('workspace-logo')).width, 150);
      expect(t.widget<Text>(key('workspace-heading')).style!.fontSize, 24);
      expect(t.widget<Text>(key('workspace-subtitle')).style!.fontSize, 11);
      final selected = t.widget<Semantics>(key('workspace-exam'));
      final unavailable = t.widget<Semantics>(key('workspace-everyday'));
      expect(selected.properties.checked, isTrue);
      expect(unavailable.properties.enabled, isFalse);
      final material = t.widget<Material>(find
          .descendant(
              of: key('workspace-exam'), matching: find.byType(Material))
          .first);
      expect(material.color, const Color(0xFFF6C238));
      expect(material.borderRadius, BorderRadius.circular(26));
      expect(t.widget<ColoredBox>(key('workspace-page')).color,
          const Color(0xFFF7F3EE));
      final inactiveMaterial = t.widget<Material>(find
          .descendant(
              of: key('workspace-everyday'), matching: find.byType(Material))
          .first);
      expect(inactiveMaterial.color, const Color(0xFFE4DED2));
      final continueButton = t.widget<FilledButton>(key('workspace-continue'));
      expect(continueButton.style!.backgroundColor!.resolve({}),
          const Color(0xFF241D05));
      await t.tap(key('workspace-exam'));
      await t.pumpAndSettle();
      expect(app.current, SurgoPage.workspace);
      await t.tap(key('workspace-everyday'));
      await t.pumpAndSettle();
      expect(app.current, SurgoPage.workspace);
      expect(app.examType, ExamType.toefl);
      final button = key('workspace-continue');
      // Continue belongs to the choice module; the brand is the page footer.
      final initialRect = t.getRect(button);
      expect(initialRect.top, t.getRect(key('workspace-everyday')).bottom + 40);
      expect(t.getRect(key('workspace-logo')).top,
          greaterThan(initialRect.bottom));
      // Test fonts can wrap more widely: natural-height content must remain
      // scrollable rather than compressing or clipping the options/CTA.
      await t.ensureVisible(button);
      await t.pumpAndSettle();
      expect(t.getRect(button).bottom, lessThanOrEqualTo(844));
      await t.tap(button);
      await t.pumpAndSettle();
      expect(app.current, SurgoPage.exam);
      expect(app.examType, ExamType.toefl);
      expect(app.session['sentinel'], 'keep');
      expect(t.takeException(), isNull);
    });
    testWidgets('workspace ${lang.name}: 320px and large text scroll',
        (t) async {
      final app = await mount(t, lang, const Size(320, 568), textScale: 1.3);
      expect(t.takeException(), isNull);
      expect(t.getRect(key('workspace-exam')).size,
          t.getRect(key('workspace-everyday')).size);
      await t.ensureVisible(key('workspace-continue'));
      await t.pumpAndSettle();
      expect(key('workspace-continue').hitTestable(), findsOneWidget);
      expect(
          t.getRect(key('workspace-continue')).bottom, lessThanOrEqualTo(568));
      expect(app.current, SurgoPage.workspace);
      expect(t.takeException(), isNull);
      // ExamSelectionPage has a pre-existing small-screen/text-scale overflow;
      // this layout test is scoped to the changed mode page. Route advancement
      // is tested above and by all four signup onboarding flows.
    });
  }
  testWidgets('workspace chrome matches exam page and global controls work',
      (t) async {
    final app = await mount(t, UiLang.zh, const Size(390, 844));
    final heading = t.getRect(key('workspace-heading'));
    final logo = t.getRect(key('workspace-logo'));
    final settings = t.getRect(key('global-设置'));
    final notifications = t.getRect(key('global-消息通知'));
    final headingStyle = t.widget<Text>(key('workspace-heading')).style!;
    app.go(SurgoPage.exam);
    await t.pumpAndSettle();
    final examHeading = find.text('选择考试类型');
    final examStyle = t.widget<Text>(examHeading).style!;
    final examLogo = find.byWidgetPredicate((w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == 'assets/images/surgo_logo.png');
    expect(heading.top, t.getRect(examHeading).top + 20);
    expect(heading.center.dx, t.getRect(examHeading).center.dx);
    expect(headingStyle.fontSize, examStyle.fontSize);
    expect(headingStyle.fontWeight, examStyle.fontWeight);
    expect(logo, t.getRect(examLogo));
    expect(settings, t.getRect(key('global-设置')));
    expect(notifications, t.getRect(key('global-消息通知')));
    app.go(SurgoPage.workspace);
    await t.pumpAndSettle();
    await t.tap(key('global-设置'));
    await t.pumpAndSettle();
    expect(find.byType(GlobalMenu), findsOneWidget);
    expect(
        t.widget<GlobalMenu>(find.byType(GlobalMenu)).notifications, isFalse);
    await t.tap(key('global-设置'));
    await t.pumpAndSettle();
    expect(find.byType(GlobalMenu), findsNothing);
    await t.tap(key('global-消息通知'));
    await t.pumpAndSettle();
    expect(t.widget<GlobalMenu>(find.byType(GlobalMenu)).notifications, isTrue);
    expect(app.current, SurgoPage.workspace);
    expect(app.lang, UiLang.zh);
    expect(app.examType, ExamType.toefl);
    expect(app.session['sentinel'], 'keep');
    expect(t.takeException(), isNull);
  });
}
