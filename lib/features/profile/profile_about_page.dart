import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_state.dart';
import '../../app/routes.dart';
import 'profile_reference_ui.dart';
import 'profile_style.dart';

/// Package version is verified against pubspec.yaml in widget tests.
class ProfileAboutPage extends StatelessWidget {
  const ProfileAboutPage({super.key});
  static const packageVersion = '1.0.0 (1)';
  void detail(BuildContext context, String title, String body) {
    showDialog<void>(
        context: context,
        useRootNavigator: false,
        builder: (c) => AlertDialog(
                key: const ValueKey('profile-about-dialog'),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text(title,
                    style: profileHeading(18)),
                content: SingleChildScrollView(
                    child: Text(body, style: referenceBody)),
                actions: [
                  TextButton(
                      key: const ValueKey('profile-about-close'),
                      onPressed: () => Navigator.pop(c),
                      child: Text(context.read<AppState>().lang == UiLang.zh
                          ? '关闭'
                          : 'Close'))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final zh = context.watch<AppState>().lang == UiLang.zh;
    final entries = <String, List<String>>{
      'intro': [
        zh ? '关于应用' : 'About the app',
        zh
            ? 'SURGO 是面向雅思和托福学习者的原生 Flutter 学习原型，涵盖日常练习、模拟练习和学习回顾。'
            : 'SURGO is a native Flutter learning prototype for IELTS and TOEFL, including daily practice, mock practice and review.'
      ],
      'terms': [
        zh ? '服务条款' : 'Terms of service',
        zh
            ? '正式服务条款尚未提供。本页不是法律协议，不代表已上线的收费服务，也不会记录同意状态。'
            : 'Official terms have not been provided. This page is not a legal agreement or an active paid service and records no consent.'
      ],
      'privacy': [
        zh ? '隐私政策' : 'Privacy policy',
        zh
            ? '正式隐私政策尚未提供。当前个人中心设置保留在 AppState 本次会话内；账号安全页不收集密码或验证码。帮助页反馈只复制到剪贴板，不发送。此说明不替代正式政策，也不声明其他模块的全部数据处理行为。'
            : 'An official privacy policy has not been provided. Profile settings remain in AppState for this session; the security page collects no passwords or codes. Help feedback is copied locally, not sent. This summary is not an official policy or a complete description of other modules.'
      ],
      'privacy-summary': [
        zh ? '隐私说明（简明版）' : 'Privacy summary',
        zh
            ? '个人设置：本次会话保存。\n账号服务：尚未接入。\n反馈：仅复制，不发送。\n请勿在反馈中填写密码、验证码或敏感信息。'
            : 'Profile settings: current session only.\nAccount service: not connected.\nFeedback: copied, never sent.\nDo not include passwords, verification codes or sensitive information in feedback.'
      ],
      'capabilities': [
        zh ? '原型功能说明' : 'Prototype capabilities',
        zh
            ? '部分成绩和口语评语为示例内容；录音计时不等于真实语音分析。登录、密码、绑定、注销尚未接入真实账号服务。个人中心编辑需点击保存设置，本次会话以外的持久化尚未实现。'
            : 'Some scores and speaking feedback are examples. Recording timers do not establish real speech analysis. Login, password, binding and account deletion are not connected to an account service. Profile edits require Save settings and are not persisted across restarts.'
      ],
      'version': [
        zh ? '版本信息' : 'Version information',
        zh
            ? 'SURGO Flutter\n软件包版本：$packageVersion\n版本来源：工程 pubspec.yaml。\n这是本地开发预览，不代表 App Store 已发布版本。'
            : 'SURGO Flutter\nPackage version: $packageVersion\nSource: project pubspec.yaml.\nThis is a local development preview, not an App Store release.'
      ],
    };
    return ProfileReferencePage(
      key: const ValueKey('profile-about-page'),
      title: zh ? '关于 SURGO' : 'About SURGO',
      backKey: 'profile-about-back',
      scrollKey: 'profile-about-scroll',
      footer: Text(
          zh
              ? 'SURGO · 雅思 / 托福学习\n本地开发预览'
              : 'SURGO · IELTS / TOEFL Learning\nLocal development preview',
          textAlign: TextAlign.center,
          style: referenceBody.copyWith(
              color: ProfileReferenceColors.muted, fontSize: 12)),
      children: [
        ProfileReferenceGroup(children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 44),
              child: Column(children: [
                Image.asset('assets/images/surgo_logo.png',
                    width: 160,
                    key: const ValueKey('profile-about-logo'),
                    semanticLabel: 'SURGO'),
                const SizedBox(height: 20),
                Text(zh ? '版本 $packageVersion' : 'Version $packageVersion',
                    key: const ValueKey('profile-about-version-label'),
                    style: referenceBody.copyWith(
                        color: ProfileReferenceColors.muted)),
              ])),
          for (final entry in entries.entries)
            ProfileReferenceRow(
                rowKey: ValueKey('profile-about-${entry.key}'),
                label: entry.value[0],
                onTap: () => detail(context, entry.value[0], entry.value[1])),
        ])
      ],
    );
  }
}
