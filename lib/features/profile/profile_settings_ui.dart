import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_state.dart';
import '../../app/routes.dart';
import '../../theme/tokens.dart';
import 'profile_reference_ui.dart';

import 'profile_style.dart';
export 'profile_style.dart';

class ProfileSettingsLayout extends StatelessWidget {
  const ProfileSettingsLayout({super.key, required this.title, required this.backKey,
    required this.children, this.footer});
  final String title, backKey;
  final List<Widget> children;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => Column(children: [
    ProfileSettingsHeader(title: title, backKey: backKey),
    Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: children)),
    if (footer != null) SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), child: footer)),
  ]);
}

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22),
      border: Border.all(color: SurgoColors.line.withValues(alpha: .65))), child: child);
}

class ProfileLanguagePage extends StatelessWidget {
  const ProfileLanguagePage({super.key});
  Future<void> chooseLanguage(BuildContext context) async {
    final app = context.read<AppState>();
    await showModalBottomSheet<void>(context: context, useRootNavigator: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ChangeNotifierProvider.value(value: app,
        child: Consumer<AppState>(builder: (context, state, _) =>
          SafeArea(child: Padding(padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width:36,height:4,decoration:BoxDecoration(
                color:ProfileReferenceColors.line,borderRadius:BorderRadius.circular(8))),
              const SizedBox(height:16),
              Text(state.lang == UiLang.zh ? 'App语言' : 'App language',
                style:profileHeading(18)),
              for(final lang in UiLang.values) RadioListTile<UiLang>(
                key:ValueKey('profile-language-${lang.name}'),
                value:lang,groupValue:state.lang,
                activeColor:SurgoColors.onYellowStrong,
                title:Text(lang == UiLang.zh ? '简体中文' : 'English',style:referenceBody),
                onChanged:(v) { if(v!=null) app.setLang(v); Navigator.pop(context); }),
            ]))))));
  }
  @override
  Widget build(BuildContext context) {
    final app=context.watch<AppState>();
    final zh=app.lang==UiLang.zh;
    return ProfileReferencePage(key:const ValueKey('profile-language-page'),
      title:zh?'语言设置':'Language',backKey:'profile-language-back',
      children:[
        ProfileReferenceGroup(children:[ProfileReferenceRow(
          rowKey:const ValueKey('profile-language-picker'),
          label:zh?'App语言':'App language',
          value:zh?'简体中文':'English',onTap:()=>chooseLanguage(context))]),
        ProfileReferenceSection(zh?'题目与学习内容':'Questions and learning content'),
        ProfileReferenceGroup(children:[
          ProfileReferenceRow(label:zh?'题目语言':'Question language',value:'English'),
          ProfileReferenceRow(label:zh?'阅读文章与听力原文':'Passages and transcripts',value:'English'),
        ]),
        ProfileReferenceNote(zh?'题目语言不变：阅读文章、听力原文、题干和选项保留英文；界面语言不会修改考试内容。'
          :'Question language stays the same: passages, transcripts, stems and options remain in English.'),
        ProfileReferenceSection(zh?'翻译':'Translation'),
        ProfileReferenceGroup(children:[ProfileReferenceRow(
          label:zh?'自动翻译考试内容':'Auto-translate exam content',
          value:zh?'不启用':'Not enabled')]),
        ProfileReferenceNote(zh?'界面语言选择后立即生效。设置仅保留在本次使用中，尚未同步到账号。'
          :'App language changes immediately. This setting lasts for the current session and is not synced to an account.'),
      ]);
  }
}
