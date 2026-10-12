import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/app/shell.dart';
import 'package:surgo_flutter/features/profile/profile_detail_route.dart';
import 'package:surgo_flutter/features/profile/profile_entry_interaction.dart';
import 'package:surgo_flutter/features/profile/profile_style.dart';
import 'package:surgo_flutter/features/profile/profile_reference_ui.dart';
import 'package:surgo_flutter/theme/app_theme.dart';

void main() {
  setUpAll(() async { await Translator.load(); await QuestionBank.load(); });
  Future<AppState> mount(WidgetTester t, {bool reduced = false}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final app = AppState(current: SurgoPage.prep, lang: UiLang.zh);
    await t.pumpWidget(ChangeNotifierProvider.value(value: app,
      child: MaterialApp(theme: SurgoTheme.build(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!),
        home: const SurgoShell())));
    await t.pumpAndSettle();
    return app;
  }
  final entry = find.byKey(const ValueKey('profile-账号安全'));
  final header = find.byType(ProfileSettingsHeader);
  final back = find.byKey(const ValueKey('profile-security-back'));

  testWidgets('push and pop slide naturally, keeping profile scroll position', (t) async {
    await mount(t);
    await t.ensureVisible(entry);
    final before = t.getRect(entry);
    await t.tap(entry); await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    final entering = t.getRect(header).left;
    final route = ModalRoute.of(t.element(header))!;
    expect(route, isA<CupertinoPageRoute<bool>>());
    expect(route.animation!.value, inExclusiveRange(0.0, 1.0));
    await t.pumpAndSettle();
    final resting = t.getRect(header).left;
    expect(entering, greaterThan(resting));
    await t.tap(back); await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(t.getRect(header).left, greaterThan(resting));
    await t.pumpAndSettle();
    expect(header, findsNothing);
    expect(t.getRect(entry), before);
    expect(t.takeException(), isNull);
  });

  testWidgets('rapid entry taps never stack duplicate profile pages', (t) async {
    await mount(t); await t.ensureVisible(entry);
    final context = t.element(entry);
    final first = openProfileDetail(context, '账号安全');
    final duplicate = openProfileDetail(context, '语言设置');
    await t.pumpAndSettle();
    expect(header, findsOneWidget);
    expect(find.byKey(const ValueKey('profile-language-page')), findsNothing);
    await t.tap(back); await t.pumpAndSettle();
    expect(await first, isNull); expect(await duplicate, isNull);
    expect(header, findsNothing);
    await t.tap(entry); await t.pumpAndSettle();
    expect(header, findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('edge swipe can cancel or complete without changing app data', (t) async {
    final app = await mount(t);
    await t.ensureVisible(entry); await t.tap(entry); await t.pumpAndSettle();
    final page = t.getRect(find.byType(ProfileReferencePage));
    final initial = t.getRect(header).left;
    var gesture = await t.startGesture(Offset(page.left + 2, page.center.dy));
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(const Offset(40, 0));
    await t.pump(const Duration(milliseconds: 100));
    expect(t.getRect(header).left, greaterThan(initial));
    await t.pump(const Duration(milliseconds: 400));
    await gesture.up(); await t.pumpAndSettle();
    expect(header, findsOneWidget);
    expect(t.getRect(header).left, closeTo(initial, .1));
    gesture = await t.startGesture(Offset(page.left + 2, page.center.dy));
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(Offset(page.width * .8, 0));
    await t.pump(const Duration(milliseconds: 100));
    await gesture.up(); await t.pumpAndSettle();
    expect(header, findsNothing);
    expect(app.session, isEmpty);
    expect(t.takeException(), isNull);
  });

  testWidgets('reduced motion skips route translation and reverse duration', (t) async {
    await mount(t, reduced: true);
    await t.ensureVisible(entry); await t.tap(entry); await t.pumpAndSettle();
    final route = ModalRoute.of(t.element(header))! as PageRoute;
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    await t.tap(back); await t.pumpAndSettle();
    expect(header, findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('entry has press feedback, cancels outside, and supports keyboard', (t) async {
    var count = 0;
    await t.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: ProfileEntryInteraction(onTap: () => count++,
        child: const SizedBox(width: 240, height: 72, child: Text('Settings')))))));
    final target = find.byType(ProfileEntryInteraction);
    final rect = t.getRect(target);
    var gesture = await t.startGesture(rect.center);
    await t.pump(const Duration(milliseconds: 100));
    expect(t.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, .992);
    expect((t.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration).color,
      Colors.transparent);
    await gesture.moveTo(rect.bottomRight + const Offset(30, 30));
    await gesture.up(); await t.pumpAndSettle();
    expect(count, 0);
    await t.tap(target); await t.pumpAndSettle(); expect(count, 1);
    final detector = find.byType(FocusableActionDetector);
    Focus.of(t.element(find.descendant(of: detector,
        matching: find.byType(Listener)).first)).requestFocus();
    await t.pump(); await t.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(count, 2);
    expect((t.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration).color,
      Colors.transparent);
    expect(t.takeException(), isNull);
  });
}
