import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/app/shell.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/features/report/learning_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Translator.load();
    await QuestionBank.load();
  });
  Future<AppState> mount(WidgetTester t,
      {double width = 390, UiLang lang = UiLang.zh}) async {
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

  Future<void> enter(WidgetTester t, String key, String value) async {
    final f = find.byKey(ValueKey(key));
    await t.ensureVisible(f);
    await t.enterText(f, value);
    await t.pump();
  }

  String value(WidgetTester t, String field) =>
      t.widget<Text>(find.byKey(ValueKey('profile-exam-$field-value'))).data!;
  Future<void> edit(WidgetTester t, String field, String text) async {
    await tap(t, 'profile-exam-$field-edit');
    await enter(t, 'profile-exam-$field', text);
    await tap(t, 'profile-value-confirm');
  }

  testWidgets(
      'exam rows validate dialog edits, save and retain per-exam drafts',
      (t) async {
    final app = await mount(t);
    await tap(t, 'profile-考试信息');
    expect(find.byType(TextFormField), findsNothing);
    await edit(t, 'target', '99');
    expect(find.text('请输入 0–9 之间的分数'), findsOneWidget);
    expect(value(t, 'target'), '7.0');
    expect(app.session['reportTarget-ielts'], isNull);
    await enter(t, 'profile-exam-target', '7.3');
    await tap(t, 'profile-value-confirm');
    expect(find.text('目标分数请以 0.5 分递增'), findsOneWidget);
    await enter(t, 'profile-exam-target', '7.5');
    await tap(t, 'profile-value-confirm');
    await edit(t, 'current', '6.5');
    await edit(t, 'date', '2026-02-30');
    expect(find.text('请输入有效日期，如 2026-11-01'), findsOneWidget);
    final date = DateTime.now().add(const Duration(days: 50));
    final dateValue =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await enter(t, 'profile-exam-date', dateValue);
    await tap(t, 'profile-value-confirm');
    expect(value(t, 'date'), dateValue);
    expect(
        app.session['reportTarget-ielts'], isNull); // Dialog edits are drafts.
    await tap(t, 'profile-exam-save');
    expect(find.byKey(const ValueKey('profile-exam-page')), findsNothing);
    expect(app.session['profileCurrent-ielts'], 6.5);
    expect(app.session['reportTarget-ielts'], 7.5);
    expect(find.text('目标 7.5'), findsOneWidget);
    final report = LearningReportData(
        exam: app.examType,
        targetOverride: app.session['reportTarget-ielts'],
        dateOverride: app.session['reportDate-ielts']);
    expect(report.target, 7.5);
    expect(report.daysLeft, 50);
    await tap(t, 'profile-考试信息');
    expect(value(t, 'target'), '7.5');
    await tap(t, 'profile-exam-toefl');
    expect(value(t, 'target'), '5.0');
    await edit(t, 'target', '7.0');
    expect(find.text('请输入 0–6 之间的分数'), findsOneWidget);
    await enter(t, 'profile-exam-target', '5.5');
    await tap(t, 'profile-value-confirm');
    expect(app.examType, ExamType.ielts);
    await tap(t, 'profile-exam-ielts');
    expect(value(t, 'target'), '7.5');
    await tap(t, 'profile-exam-toefl');
    expect(value(t, 'target'), '5.5');
    await tap(t, 'profile-exam-save');
    expect(app.examType, ExamType.toefl);
    expect(app.session['reportTarget-toefl'], 5.5);
    expect(app.session['reportTarget-ielts'], 7.5);
    expect(t.takeException(), isNull);
  });
  testWidgets('language changes immediately and survives return', (t) async {
    final app = await mount(t);
    await tap(t, 'profile-语言设置');
    await tap(t, 'profile-language-picker');
    await tap(t, 'profile-language-en');
    expect(app.lang, UiLang.en);
    expect(find.text('App language'), findsOneWidget);
    await tap(t, 'profile-language-back');
    expect(find.text('Profile'), findsOneWidget);
    await tap(t, 'profile-语言设置');
    await tap(t, 'profile-language-picker');
    await tap(t, 'profile-language-zh');
    expect(app.lang, UiLang.zh);
    expect(t.takeException(), isNull);
  });
  for (final lang in UiLang.values) {
    testWidgets(
        'all settings pages at 320px ${lang.name}, security does not mutate account',
        (t) async {
      final app = await mount(t, width: 320, lang: lang);
      for (final e in {
        '考试信息': 'exam',
        '账号安全': 'security',
        '语言设置': 'language',
        '帮助与支持': 'help'
      }.entries) {
        await tap(t, 'profile-${e.key}');
        expect(find.byKey(ValueKey('profile-${e.value}-page')), findsOneWidget);
        expect(t.takeException(), isNull);
        if (e.value == 'help') {
          expect(find.byKey(const ValueKey('profile-help-search')), findsNothing);
          expect(find.text('FAQ'), findsNothing);
          expect(find.text('常见问题'), findsNothing);
          expect(find.text('Frequently asked questions'), findsNothing);
          expect(find.text('需要一点帮助？'), findsNothing);
          expect(find.text('查看常见问题与练习功能说明。'), findsNothing);
          expect(find.text('A little help goes a long way.'), findsNothing);
          expect(find.text('Browse common questions about practice and this prototype.'), findsNothing);
          final scroll = t.getRect(find.byKey(const ValueKey('profile-help-scroll')));
          final first = t.getRect(find.byKey(const ValueKey('profile-help-faq-card-start')));
          expect(first.top - scroll.top, closeTo(4, .01));
        }
        if (e.value == 'security') {
          final snapshot = Map<String, dynamic>.from(app.session);
          await tap(t, 'profile-security-password');
          expect(find.byKey(const ValueKey('profile-security-password-dialog')),
              findsOneWidget);
          expect(app.session, snapshot);
          await tap(t, 'profile-security-detail-close');
        }
        await tap(t, 'profile-${e.value}-back');
      }
    });
  }
  testWidgets(
      'dialog cancel, calendar cancel and page back preserve saved values',
      (t) async {
    final app = await mount(t);
    await tap(t, 'profile-考试信息');
    await tap(t, 'profile-exam-target-edit');
    await enter(t, 'profile-exam-target', '8.0');
    await tap(t, 'profile-value-cancel');
    expect(value(t, 'target'), '7.0');
    await edit(t, 'target', '8.0');
    await tap(t, 'profile-exam-back');
    expect(app.session['reportTarget-ielts'], isNull);
    await tap(t, 'profile-考试信息');
    expect(value(t, 'target'), '7.0');
    final originalDate = value(t, 'date');
    await tap(t, 'profile-exam-date-edit');
    await tap(t, 'profile-exam-calendar');
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await t.tap(find.descendant(
        of: find.byType(DatePickerDialog), matching: find.text('取消')));
    await t.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(
        t
            .widget<TextFormField>(
                find.byKey(const ValueKey('profile-exam-date')))
            .controller!
            .text,
        originalDate);
    await tap(t, 'profile-value-cancel');
    expect(value(t, 'date'), originalDate);
    expect(find.byType(TextFormField), findsNothing);
    expect(t.takeException(), isNull);
  });
  for (final lang in UiLang.values) {
    testWidgets('single-line labels, values and pencils at 320px ${lang.name}',
        (t) async {
      final app = await mount(t, width: 320, lang: lang);
      await tap(t, 'profile-考试信息');
      expect(find.byType(TextFormField), findsNothing);
      for (final field in ['current', 'target', 'date']) {
        final row = find.byKey(ValueKey('profile-exam-$field-row'));
        await t.ensureVisible(row);
        await t.pumpAndSettle();
        final label =
            t.getRect(find.byKey(ValueKey('profile-exam-$field-label')));
        final number =
            t.getRect(find.byKey(ValueKey('profile-exam-$field-value')));
        final pencil =
            t.getRect(find.byKey(ValueKey('profile-exam-$field-edit')));
        expect(label.right, lessThan(number.left));
        expect(number.right, lessThanOrEqualTo(pencil.left));
        expect(label.center.dy, closeTo(number.center.dy, .01));
        expect(pencil.center.dy, closeTo(number.center.dy, .01));
        await tap(t, 'profile-exam-$field-edit');
        expect(
            find.byKey(const ValueKey('profile-value-dialog')), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
        await tap(t, 'profile-value-cancel');
        expect(t.takeException(), isNull);
      }
      expect(app.session, isEmpty);
    });
  }
  testWidgets('help keeps answers and local draft without copy controls or about block',
      (t) async {
    await mount(t);
    String? copied;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() =>
        messenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tap(t, 'profile-帮助与支持');
    expect(find.byKey(const ValueKey('profile-help-search')), findsNothing);
    expect(find.byKey(const ValueKey('profile-help-clear-search')), findsNothing);
    expect(find.text('常见问题'), findsNothing);
    expect(find.text('FAQ'), findsNothing);
    for (final id in ['start', 'switch-exam', 'daily-mock', 'grading',
        'recording', 'account', 'language', 'feedback']) {
      expect(find.byKey(ValueKey('profile-help-faq-card-$id')), findsOneWidget);
    }
    await tap(t, 'profile-help-faq-grading');
    expect(find.textContaining('不要作为正式考试成绩'), findsOneWidget);
    await enter(t, 'profile-feedback-text', '希望增加练习提示');
    expect(find.byKey(const ValueKey('profile-feedback-copy')), findsNothing);
    expect(find.text('复制反馈文案'), findsNothing);
    expect(find.text('关于 SURGO'), findsNothing);
    final preview = t.widget<SelectableText>(find.byType(SelectableText));
    expect(preview.data, contains('未发送'));
    expect(preview.data, contains('希望增加练习提示'));
    expect(copied, isNull);
    expect(t.takeException(), isNull);
  });
}
