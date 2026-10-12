import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../app/routes.dart';
import '../../theme/tokens.dart';
import 'profile_reference_ui.dart';
import 'profile_style.dart';

/// Dialog body style: the page rows come from the shared reference widgets,
/// while the explanatory dialogs keep their own slightly looser rhythm.
const _body = profileBody;

/// Informational prototype, not an authenticated account-management surface.
///
/// Style follows the exam settings page: warm canvas, a small
/// centred identity block, and white grouped rows with a line icon, a left
/// label and a disclosure arrow. Push inside the phone Navigator with
/// a bounded viewport. The route owner supplies Material and the existing
/// status-bar inset; do not add another here. Only disclosure state and local
/// dialog routes change. AppState is read solely for language, and the identity
/// below intentionally matches the profile fixture.
class ProfileSecurityPage extends StatelessWidget {
  const ProfileSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final zh = context.watch<AppState>().lang == UiLang.zh;
    return KeyedSubtree(
      key: const ValueKey('profile-security-page'),
      child: ProfileReferencePage(
        title: '',
        backKey: 'profile-security-back',
        backOffsetY: 20,
        scrollKey: 'profile-security-scroll',
        children: [
          _IdentityBlock(zh: zh),
          ProfileReferenceSection(zh ? '登录与验证' : 'Sign-in & verification'),
          ProfileReferenceGroup(
            children: [
              for (final topic in const [
                _SecurityTopic.password,
                _SecurityTopic.email,
                _SecurityTopic.linkedAccounts,
              ])
                _TopicRow(topic: topic, zh: zh),
            ],
          ),
          ProfileReferenceSection(zh ? '隐私与数据' : 'Privacy & data'),
          ProfileReferenceGroup(
            children: [
              for (final topic in const [
                _SecurityTopic.privacy,
                _SecurityTopic.sessions,
                _SecurityTopic.deletion,
              ])
                _TopicRow(topic: topic, zh: zh),
            ],
          ),
          ProfileReferenceNote(
            zh
                ? '本页仅供说明，不收集密码或验证码，也不发送网络请求。'
                : 'This page is informational only. It collects no passwords or codes and makes no network requests.',
          ),
        ],
      ),
    );
  }
}

/// Small centred avatar + example name, replacing the previous oversized card.
class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({required this.zh});

  final bool zh;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
        child: Column(
          children: [
            Semantics(
              image: true,
              label: zh ? '个人头像' : 'Profile avatar',
              child: const CircleAvatar(
                key: ValueKey('profile-security-avatar'),
                radius: 24,
                backgroundColor: SurgoColors.yellowTint,
                backgroundImage: AssetImage('assets/images/profile_avatar_20261012.png'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Miki Jin',
              style: profileHeading(17),
            ),
            const SizedBox(height: 3),
            Text(
              'miki.jin@example.com',
              style: referenceBody.copyWith(
                  fontSize: 12, color: ProfileReferenceColors.muted),
            ),
          ],
        ),
      );
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.zh});

  final _SecurityTopic topic;
  final bool zh;

  @override
  Widget build(BuildContext context) => MergeSemantics(
        child: Semantics(
          button: true,
          hint: zh ? '打开说明，不执行账号操作' : 'Open details, not an account action',
          child: ProfileReferenceRow(
            rowKey: ValueKey('profile-security-${topic.id}'),
            icon: topic.icon,
            label: topic.title(zh),
            singleLineLabel: topic == _SecurityTopic.sessions,
            onTap: () => _showDetails(context, topic),
          ),
        ),
      );
}

void _showDetails(BuildContext context, _SecurityTopic topic) {
  final app = context.read<AppState>();
  showDialog<void>(
    context: context,
    useRootNavigator: false,
    barrierColor: SurgoColors.mask,
    barrierLabel: app.lang == UiLang.zh ? '关闭说明' : 'Close details',
    // Explicitly bridge the provider if it lives below the phone Navigator.
    builder: (_) => ChangeNotifierProvider<AppState>.value(
      value: app,
      child: _SecurityDetailDialog(topic: topic),
    ),
  );
}

class _SecurityDetailDialog extends StatefulWidget {
  const _SecurityDetailDialog({required this.topic});
  final _SecurityTopic topic;
  @override
  State<_SecurityDetailDialog> createState() => _SecurityDetailDialogState();
}

class _SecurityDetailDialogState extends State<_SecurityDetailDialog> {
  bool _deleteAttempted = false;

  @override
  Widget build(BuildContext context) {
    final zh = context.watch<AppState>().lang == UiLang.zh;
    final topic = widget.topic;
    final deletion = topic == _SecurityTopic.deletion;
    final paragraphs = topic.details(zh);
    return AlertDialog(
      key: ValueKey('profile-security-${topic.id}-dialog'),
      backgroundColor: SurgoColors.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: SurgoRadius.dialogAll),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      scrollable: true,
      title: Text(topic.title(zh), style: profileHeading(18),
          textAlign: deletion ? TextAlign.center : TextAlign.start),
      actionsAlignment: deletion ? MainAxisAlignment.center : MainAxisAlignment.end,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!deletion) Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: SurgoColors.yellowTint,
              borderRadius: SurgoRadius.chipAll,
            ),
            child: Text(
              zh
                  ? '仅供说明 · 真实账号服务未接入'
                  : 'Information only · no live account service',
              style: _body.copyWith(color: SurgoColors.onYellowStrong),
            ),
          ),
          for (var i = 0; i < paragraphs.length; i++) ...[
            if (i > 0 || !deletion) const SizedBox(height: 14),
            Text(paragraphs[i], style: _body),
          ],
        ],
      ),
      actions: [
        if (deletion) _deletionActions(zh) else TextButton(
          key: const ValueKey('profile-security-detail-close'),
          style: TextButton.styleFrom(
            minimumSize: const Size(88, 48),
            backgroundColor: SurgoColors.yellow,
            foregroundColor: SurgoColors.onYellowStrong,
            shape:
                const RoundedRectangleBorder(borderRadius: SurgoRadius.btnAll),
            textStyle: profileHeading(16),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(zh ? '关闭' : 'Close'),
        ),
      ],
    );
  }

  Widget _deletionActions(bool zh) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        key: const ValueKey('profile-security-delete-actions'),
        children: [
          Expanded(flex: 3, child: TextButton(
            key: const ValueKey('profile-security-delete-confirm'),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: SurgoColors.yellow,
              foregroundColor: SurgoColors.onYellowStrong,
              shape: const RoundedRectangleBorder(borderRadius: SurgoRadius.btnAll),
              textStyle: profileHeading(16),
            ),
            // No account service is connected; never simulate deletion success.
            onPressed: () => setState(() => _deleteAttempted = true),
            child: FittedBox(fit: BoxFit.scaleDown,
              child: Text(zh ? '确定注销账号' : 'Confirm deletion', maxLines: 1)),
          )),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: OutlinedButton(
            key: const ValueKey('profile-security-detail-close'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: Colors.white,
              foregroundColor: SurgoColors.ink,
              side: const BorderSide(color: SurgoColors.line),
              shape: const RoundedRectangleBorder(borderRadius: SurgoRadius.btnAll),
              textStyle: profileHeading(16),
            ),
            onPressed: () => Navigator.pop(context),
            child: FittedBox(fit: BoxFit.scaleDown,
              child: Text(zh ? '关闭' : 'Close', maxLines: 1)),
          )),
        ],
      ),
      if (_deleteAttempted) Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Semantics(liveRegion: true, child: Text(
          zh ? '暂无法注销：账号服务未接入，未提交任何请求。'
              : 'Account deletion is unavailable. No request was submitted.',
          key: const ValueKey('profile-security-delete-unavailable'),
          textAlign: TextAlign.center,
          style: _body.copyWith(fontSize: 12, color: SurgoColors.muted),
        )),
      ),
    ],
  );
}

enum _SecurityTopic {
  password,
  email,
  linkedAccounts,
  privacy,
  sessions,
  deletion;

  String get id => switch (this) {
        linkedAccounts => 'linked-accounts',
        deletion => 'delete-account',
        _ => name,
      };

  IconData get icon => switch (this) {
        password => Icons.lock_outline,
        email => Icons.mail_outline,
        linkedAccounts => Icons.link,
        privacy => Icons.privacy_tip_outlined,
        sessions => Icons.devices_outlined,
        deletion => Icons.info_outline,
      };

  String title(bool zh) => switch (this) {
        password => zh ? '登录密码' : 'Password',
        email => zh ? '邮箱验证' : 'Email verification',
        linkedAccounts => zh ? '关联账号' : 'Linked accounts',
        privacy => zh ? '隐私与数据说明' : 'Privacy & data notes',
        sessions => zh ? '登录设备与退出说明' : 'Devices & sign-out notes',
        deletion => zh ? '注销账号' : 'Delete account',
      };

  List<String> details(bool zh) => switch (this) {
        password => [
            zh
                ? '密码状态未知：本页没有接入身份验证服务，无法判断示例账号是否设置过密码。'
                : 'Password status is unknown. There is no authentication service to determine whether this example account has a password.',
            zh
                ? '修改密码与找回密码目前不可用。真实操作需要验证身份、安全存储凭据和发送找回邮件的服务；本页不会收集密码，也不会发送重置邮件。'
                : 'Password changes and recovery are unavailable. Real operations require identity checks, secure credential storage and a recovery email service. This page collects no passwords and sends no reset emails.',
            zh
                ? '如需处理其他真实服务的密码，请直接使用该服务的官方找回入口，不要在演示页面输入真实凭据。'
                : 'For a real account with another service, use its official recovery page. Do not enter real credentials in a demo.',
          ],
        email => [
            zh
                ? 'miki.jin@example.com 是原型示例邮箱，不代表真实、已绑定或已验证的邮箱。'
                : 'miki.jin@example.com is a prototype example, not evidence of a real, linked or verified email address.',
            zh
                ? '验证、绑定和更换邮箱均不可用：尚无账号服务、邮件发送服务或验证码校验。本页不会发送邮件，也不会更改个人中心显示的邮箱。'
                : 'Verifying, linking and changing email are unavailable: account, email delivery and code verification services are not connected. This page sends no email and does not change the address shown in your profile.',
            zh
                ? '真实服务应先验证你对邮箱的控制权，再将它用作登录或找回方式。'
                : 'A real service should verify that you control an email address before using it for sign-in or recovery.',
          ],
        linkedAccounts => [
            zh
                ? 'Google、Apple 等第三方账号的关联状态未知。原型登录入口不代表已经完成授权或绑定。'
                : 'The link status of third-party accounts such as Google or Apple is unknown. Prototype sign-in screens do not mean authorization or linking has occurred.',
            zh
                ? '绑定与解除绑定不可用：尚未接入 OAuth 授权和账号关联服务。本页不会打开第三方授权、读取第三方资料或更改关联关系。'
                : 'Linking and unlinking are unavailable because OAuth and account-linking services are not connected. This page does not open third-party authorization, read provider data or change any links.',
            zh
                ? '在真实服务中，解除关联前应确认还有其他可用的登录方式，以免无法进入账号。'
                : 'In a real service, confirm that another sign-in method works before unlinking an account so you do not lose access.',
          ],
        privacy => [
            zh
                ? '本页只展示固定的示例身份，并读取当前界面语言。展开建议或查看说明不会保存凭据、上传资料或修改账号。'
                : 'This page displays a fixed example identity and reads the current interface language. Opening tips or details does not save credentials, upload data or modify an account.',
            zh
                ? '这里没有读取云端个人资料的接口，因此无法提供真实账号的数据副本、导出或删除。本页也不会清除本机的学习记录或偏好。'
                : 'There is no interface for cloud profile data, so real account data access, export and deletion are unavailable. This page does not clear local learning records or preferences.',
            zh
                ? '这些说明仅适用于此原型页面，不是对整个应用的数据收集、存储或保留政策的承诺。真实服务应提供正式的隐私政策与数据管理入口。'
                : 'These notes apply only to this prototype page, not as a promise about app-wide data collection, storage or retention. A live service should provide a formal privacy policy and data controls.',
          ],
        sessions => [
            zh
                ? '无法查询在线设备或登录记录：当前没有真实的登录会话服务，因此本页不展示虚构的设备或最近活动。'
                : 'Online devices and sign-in history cannot be queried. No live session service is connected, so this page does not invent devices or recent activity.',
            zh
                ? '在线退出和远程退出均不可用。返回个人中心或关闭弹窗只会切换本地界面，不会撤销任何真实服务的登录凭证。'
                : 'Online and remote sign-out are unavailable. Returning to your profile or closing this dialog only changes the local interface; it does not revoke credentials for any real service.',
            zh
                ? '如怀疑其他真实账号被访问，请在对应服务的官方安全设置中检查会话并撤销不认识的设备。'
                : 'If you suspect access to a real account elsewhere, review sessions in that service’s official security settings and revoke unfamiliar devices.',
          ],
        deletion => [
            zh
                ? '注销账号目前不可用：尚未接入账号服务、身份确认或数据删除接口。没有任何注销请求会被提交。'
                : 'Account deletion is unavailable: account, identity confirmation and data deletion services are not connected. No deletion request will be submitted.',
            zh
                ? '本页不会删除示例身份、云端资料或本地学习记录。关闭说明不代表确认或完成注销。'
                : 'This page does not delete the example identity, cloud data or local learning records. Closing these notes does not confirm or complete deletion.',
            zh
                ? '真实的注销流程应明确说明影响、数据保留规则和是否可撤回，并在验证身份后取得你的明确确认。'
                : 'A real deletion flow should explain its effects, data retention and whether it can be reversed, then verify your identity and obtain explicit confirmation.',
          ],
      };
}
