import '../../widgets/source_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_state.dart';
import '../../app/i18n.dart';
import '../../app/routes.dart';
import '../../theme/tokens.dart';
import '../../widgets/primitives.dart';
import '../../widgets/t.dart';
import 'workspace_page.dart';
Widget? buildLegacyEntryPage(SurgoPage page)=>switch(page){SurgoPage.workspace=>const WorkspacePage(),SurgoPage.examTimer=>const _ExamTimer(),_=>null};
const examFallbacks={
 'listening':('听力','30:00','四个部分共 40 题 · 录音仅播放一次',['S1 · 对话','S2 · 独白','S3 · 讨论','S4 · 讲座'],SurgoPage.listeningSession,'开始第 1 部分 →'),
 'reading':('阅读','60:00','3 篇文章共 40 题 · 60 分钟',['Passage 1','Passage 2','Passage 3'],SurgoPage.readingSession,'开始 Passage 1 →'),
 'speaking':('口语','14:00','三个部分 · 约 11–14 分钟',['Part 1','Part 2','Part 3'],SurgoPage.speakingSession,'开始 Part 1 →'),
 'writing':('写作','60:00','Task 1 与 Task 2 共用 60 分钟',['Task 1 · 150 词','Task 2 · 250 词'],SurgoPage.writingSession,'开始 Task 1 →'),
};
/// Source fallback is a static introduction despite its route name: no timer hook.
class _ExamTimer extends StatelessWidget {
 const _ExamTimer();
 @override
 Widget build(BuildContext context){final app=context.watch<AppState>();final pick=app.session['mockPick'];final key=examFallbacks.containsKey(pick)?pick as String:'writing';final e=examFallbacks[key]!,body=QuestionBank.instance.skill(key,app.examType)['mock'] as Map? ?? {};
 return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const SurgoTopBar(label:'返回'),SurgoCard(child:Column(children:[Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:6),decoration:BoxDecoration(color:const Color(0xff141210),borderRadius:BorderRadius.circular(12)),child:T('${app.examType==ExamType.toefl?'TOEFL':'IELTS'} ${e.$1}模拟考',style:const TextStyle(fontFamily: 'Outfit', fontFamilyFallback: SurgoFontFamily.fallback, fontSize:10,color:Colors.white,fontWeight:FontWeight.w700))),const SizedBox(height:20),SourceText(e.$2,style:const TextStyle(fontFamily: 'Outfit', fontFamilyFallback: SurgoFontFamily.fallback, fontSize:50,fontWeight:FontWeight.w800)),T(e.$3,style:SurgoText.sub)])),const SizedBox(height:20),
 Wrap(spacing:14,runSpacing:12,children:[for(var i=0;i<e.$4.length;i++)Row(mainAxisSize:MainAxisSize.min,children:[CircleAvatar(radius:13,backgroundColor:i==0?SurgoColors.yellow:SurgoColors.line,child:SourceText('${i+1}',style:const TextStyle(fontSize:11))),const SizedBox(width:6),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SourceText('Step ${i+1}',style:const TextStyle(fontSize:10)),T(e.$4[i],style:const TextStyle(fontSize:11))])])]),const SizedBox(height:20),
 SurgoCard(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[SourceText(body['summary']??'',style:SurgoText.cardTitle),const SizedBox(height:8),SourceText(body['intro']??'',style:SurgoText.sub)])),const SizedBox(height:14),SurgoButton(e.$6,onTap:()=>app.go(e.$5)),
 ]);}
}
