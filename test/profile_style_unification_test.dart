import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/app/shell.dart';
import 'package:surgo_flutter/features/profile/profile_style.dart';
import 'package:surgo_flutter/features/profile/profile_reference_ui.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/theme/tokens.dart';

void main() {
  setUpAll(() async { await Translator.load(); await QuestionBank.load(); });
  for(final lang in UiLang.values) {
    for(final width in [320.0,390.0]) {
      testWidgets('five profile pages share exam typography ${lang.name} $width', (t) async {
        t.view.physicalSize=Size(width,844);t.view.devicePixelRatio=1;
        addTearDown(t.view.reset);
        final app=AppState(current:SurgoPage.prep,lang:lang);
        await t.pumpWidget(ChangeNotifierProvider.value(value:app,
          child:MaterialApp(theme:SurgoTheme.build(),home:const SurgoShell())));
        await t.pumpAndSettle();
        Rect? baselineHeader;
        for(final entry in {'考试信息':'exam','账号安全':'security','语言设置':'language',
            '帮助与支持':'help','关于 SURGO':'about'}.entries) {
          final link=find.byKey(ValueKey('profile-${entry.key}'));
          await t.ensureVisible(link);await t.tap(link);await t.pumpAndSettle();
          final header=find.byType(ProfileSettingsHeader);
          expect(header,findsOneWidget);
          final rect=t.getRect(header);
          baselineHeader ??= rect;
          expect(rect.left,baselineHeader.left);
          expect(rect.top,baselineHeader.top - (entry.value == 'security' ? 20 : 0));
          expect(rect.width,baselineHeader.width);
          final title=t.widget<Text>(find.descendant(of:header,matching:find.byType(Text)).first);
          expect(title.style,profileHeading());
          expect(find.descendant(of:header,matching:find.byIcon(Icons.arrow_back)),findsOneWidget);
          expect(find.byWidgetPredicate((w)=>w is Material && w.color==SurgoColors.warmWhite),findsWidgets);
          for(final group in t.widgetList<ProfileReferenceGroup>(find.byType(ProfileReferenceGroup))) {
            final material=t.widget<Material>(find.descendant(
              of:find.byWidget(group),matching:find.byType(Material)).first);
            expect((material.shape! as RoundedRectangleBorder).borderRadius,
              BorderRadius.circular(22));
          }
          expect(referenceBody,profileBody);
          expect(t.takeException(),isNull);
          await t.tap(find.byKey(ValueKey('profile-${entry.value}-back')));
          await t.pumpAndSettle();
        }
        expect(app.session,isEmpty);
      });
    }
  }
}
