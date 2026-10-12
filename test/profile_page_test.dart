import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surgo_flutter/app/app_state.dart';
import 'package:surgo_flutter/app/i18n.dart';
import 'package:surgo_flutter/app/routes.dart';
import 'package:surgo_flutter/features/profile/profile_page.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(()=>Translator.load());
  Future<AppState> pump(WidgetTester tester,{UiLang lang=UiLang.zh}) async {
    final state=AppState(lang:lang,current:SurgoPage.prep);
    await tester.pumpWidget(ChangeNotifierProvider.value(value:state,child:MaterialApp(home:Scaffold(
      body:SingleChildScrollView(child:ProfilePage(now:DateTime(2026,9,21)))))));
    await tester.pumpAndSettle();
    return state;
  }
  testWidgets('fixture identity scores and exact date from source', (tester) async {
    await pump(tester);
    for(final text in ['Miki Jin','miki.jin@example.com','6.3','/9','20','目标 7.0','2026年10月11日']) {
      expect(find.text(text),findsOneWidget);
    }
    expect(tester.takeException(),isNull);
  });
  testWidgets('English date does not alter source fixture scores',(tester) async {
    await pump(tester,lang:UiLang.en);
    expect(find.text('Oct 11, 2026'),findsOneWidget);
    expect(find.text('6.3'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
  testWidgets('all five settings rows open native pages and return', (tester) async {
    await pump(tester);
    const sections = {
      '考试信息': 'exam', '账号安全': 'security',
      '语言设置': 'language', '帮助与支持': 'help', '关于 SURGO': 'about',
    };
    for (final entry in sections.entries) {
      final row = find.byKey(ValueKey('profile-${entry.key}'));
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('profile-${entry.value}-page')), findsOneWidget);
      expect(find.text('（原型）${entry.key}'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(find.byKey(ValueKey('profile-${entry.value}-back')));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('profile-${entry.value}-page')), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('logout and back only navigate as source',(tester) async {
    final state=await pump(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('profile-logout')));
    await tester.tap(find.byKey(const ValueKey('profile-logout')));await tester.pump();
    // 用户 2026-09-25：退出登录回到开屏页（原型此处去的是选科页 exam）。
    expect(state.current,SurgoPage.authSplash);
    // 退出后个人中心已不在视图里，返回键要重新挂载页面才能验证。
    final back=await pump(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('profile-back')));
    await tester.tap(find.byKey(const ValueKey('profile-back')));await tester.pump();
    expect(back.current,SurgoPage.ielts);
  });
}
