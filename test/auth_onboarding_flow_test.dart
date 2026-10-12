import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/app/shell.dart';
import 'package:surgo_flutter/pages/home_page.dart';
import 'package:surgo_flutter/pages/exam_selection_page.dart';
import 'package:surgo_flutter/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Translator.load();
    await QuestionBank.load();
  });

  Future<void> tap(WidgetTester t, String key) async {
    final target = find.byKey(ValueKey(key));
    expect(target, findsOneWidget);
    await t.ensureVisible(target);
    await t.tap(target);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  for (final lang in UiLang.values) {
    for (final exam in ExamType.values) {
      testWidgets(
          'signup -> language ${lang.name} -> mode -> ${exam.name} -> home',
          (t) async {
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final initialExam =
            exam == ExamType.ielts ? ExamType.toefl : ExamType.ielts;
        final app =
            AppState(current: SurgoPage.authSignUp, examType: initialExam);
        app.session['onboarding-test-sentinel'] = 'keep';
        await t.pumpWidget(ChangeNotifierProvider.value(
          value: app,
          child:
              MaterialApp(theme: SurgoTheme.build(), home: const SurgoShell()),
        ));
        await t.pumpAndSettle();
        await tap(t, 'auth-signup-agree');
        await tap(t, 'auth-signup-submit');
        expect(app.current, SurgoPage.authOtp);
        await tap(t, 'auth-terms-agree');
        await tap(t, 'auth-otp-continue');
        expect(app.current, SurgoPage.authCongrats);
        await tap(t, 'auth-lang-${lang.name}');

        // Registration must not skip the existing pre-home pages.
        expect(app.lang, lang);
        expect(app.current, SurgoPage.workspace);
        expect(find.byType(HomePage), findsNothing);
        expect(find.byKey(const ValueKey('workspace-exam')), findsOneWidget);
        await tap(t, 'workspace-exam');
        expect(app.current, SurgoPage.workspace);
        await tap(t, 'workspace-continue');
        expect(app.current, SurgoPage.exam);
        expect(find.byType(ExamSelectionPage), findsOneWidget);
        expect(find.byType(HomePage), findsNothing);

        // Selecting a card highlights it; only its arrow commits the exam.
        await tap(t, 'select-${exam.name}');
        expect(app.current, SurgoPage.exam);
        expect(app.examType, initialExam);
        await tap(t, 'enter-${exam.name}');
        expect(app.current, SurgoPage.ielts);
        expect(app.examType, exam);
        expect(app.lang, lang);
        expect(app.session['onboarding-test-sentinel'], 'keep');
        expect(find.byType(HomePage), findsOneWidget);
        expect(find.byType(Dialog), findsNothing);
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
      });
    }
  }
}
