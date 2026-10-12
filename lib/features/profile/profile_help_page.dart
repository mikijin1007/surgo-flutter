import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../app/routes.dart';
import '../../theme/tokens.dart';
import 'profile_style.dart';

/// Native Help & Support page. The host route supplies its Material and the
/// phone's 52px top inset; this page owns its header and scrollable content.
class ProfileHelpPage extends StatefulWidget {
  const ProfileHelpPage({super.key});

  @override
  State<ProfileHelpPage> createState() => _ProfileHelpPageState();
}

class _ProfileHelpPageState extends State<ProfileHelpPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final Set<String> _expandedFaqs = <String>{};
  String _feedbackCategory = 'content';

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zh = context.watch<AppState>().lang == UiLang.zh;

    return DecoratedBox(
      key: const ValueKey('profile-help-page'),
      decoration: const BoxDecoration(color: _helpBackground),
      child: Column(
        children: [
          ProfileSettingsHeader(
            title: zh ? '帮助与支持' : 'Help & Support', backKey: 'profile-help-back'),
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('profile-help-scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                24 + MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _helpFaqs.length; i++) ...[
                    _faqTile(_helpFaqs[i], zh),
                    if (i != _helpFaqs.length - 1)
                      const SizedBox(height: 9),
                  ],
                  const SizedBox(height: 24),
                  _sectionHeading(
                    zh ? '给我们留个建议' : 'Share feedback',
                    zh ? '本地草稿' : 'LOCAL DRAFT',
                  ),
                  const SizedBox(height: 10),
                  _feedbackCard(zh),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String eyebrow) => Wrap(
        spacing: 12,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: SurgoFontFamily.heading,
                fontFamilyFallback: SurgoFontFamily.fallback,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _helpInk,
              ),
            ),
          ),
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: SurgoFontFamily.heading,
              fontFamilyFallback: SurgoFontFamily.fallback,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: _helpMuted,
            ),
          ),
        ],
      );

  Widget _faqTile(_HelpFaq faq, bool zh) => Container(
        key: ValueKey('profile-help-faq-card-${faq.id}'),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _helpLine.withValues(alpha: .65)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: _helpRipple,
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              key: ValueKey('profile-help-faq-${faq.id}'),
              initiallyExpanded: _expandedFaqs.contains(faq.id),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  _expandedFaqs.add(faq.id);
                } else {
                  _expandedFaqs.remove(faq.id);
                }
              },
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              iconColor: _helpMuted,
              collapsedIconColor: _helpMuted,
              title: Text(
                faq.question(zh),
                style: _bodyStyle(size: 14, weight: FontWeight.w700),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    faq.answer(zh),
                    style: _bodyStyle(
                      size: 13,
                      color: _helpMuted,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _feedbackCard(bool zh) {
    final hasText = _feedbackController.text.trim().isNotEmpty;
    final preview = _feedbackText(zh);

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            zh
                ? '选择类别，描述发生的情况与期望的结果。草稿仅在本页保留，离开后不会保存。请勿填写密码、验证码或敏感信息。'
                : 'Choose a category and describe what happened and what you expected. This draft is not saved when you leave. Do not include passwords, verification codes or sensitive information.',
            style: _bodyStyle(size: 13, color: _helpMuted, height: 1.5),
          ),
          const SizedBox(height: 14),
          _fieldLabel(zh ? '类别' : 'Category'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final category in _feedbackCategories)
                ChoiceChip(
                  key: ValueKey('profile-feedback-category-$category'),
                  label: Text(_categoryLabel(category, zh)),
                  labelStyle: _bodyStyle(size: 13, weight: FontWeight.w600),
                  selected: _feedbackCategory == category,
                  showCheckmark: false,
                  selectedColor: _helpSelected,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: _feedbackCategory == category
                        ? SurgoColors.yellow
                        : _helpLine,
                    width: _feedbackCategory == category ? 1.5 : 1,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: VisualDensity.standard,
                  onSelected: (selected) {
                    if (!selected) return;
                    setState(() {
                      _feedbackCategory = category;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
          _fieldLabel(zh ? '描述' : 'Description'),
          const SizedBox(height: 6),
          TextField(
            key: const ValueKey('profile-feedback-text'),
            controller: _feedbackController,
            onChanged: (_) => setState(() {}),
            minLines: 4,
            maxLines: 6,
            maxLength: 1000,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            style: _bodyStyle(size: 14),
            decoration: InputDecoration(
              labelText: zh ? '反馈描述' : 'Feedback description',
              labelStyle: _bodyStyle(size: 13, color: _helpMuted),
              hintMaxLines: 4,
              hintText: zh ? '写下你的建议或遇到的情况…' : 'Tell us what happened or what could be better…',
              hintStyle: _bodyStyle(size: 13, color: _helpMuted),
              alignLabelWithHint: true,
              filled: true,
              fillColor: _helpBackground,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: _inputBorder(),
              focusedBorder: _inputBorder(focused: true),
              counterStyle: _bodyStyle(size: 12, color: _helpMuted),
            ),
          ),
          if (hasText) ...[
            const SizedBox(height: 14),
            Text(
              zh ? '本地预览 · 未发送' : 'LOCAL PREVIEW · NOT SENT',
              style: const TextStyle(
                fontFamily: SurgoFontFamily.heading,
                fontFamilyFallback: SurgoFontFamily.fallback,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: .35,
                color: _helpMuted,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _helpInfo,
                border: Border.all(color: _helpLine.withValues(alpha: .65)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                preview,
                style: _bodyStyle(size: 12, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _feedbackText(bool zh) {
    final category = _categoryLabel(_feedbackCategory, zh);
    final description = _feedbackController.text.trim();
    return zh
        ? 'SURGO 反馈 · 未发送\n分类：$category\n\n$description'
        : 'SURGO feedback · NOT SENT\nCategory: $category\n\n$description';
  }

  Widget _whiteCard({required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _helpLine.withValues(alpha: .65)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: child,
      );

  Widget _fieldLabel(String label) => Text(
        label,
        style: _bodyStyle(size: 13, weight: FontWeight.w700),
      );

  OutlineInputBorder _inputBorder({bool focused = false}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: focused ? SurgoColors.yellow : _helpLine,
          width: focused ? 1.5 : 1,
        ),
      );

  TextStyle _bodyStyle({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color color = _helpInk,
    double height = 1.55,
  }) => profileBody.copyWith(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );

  static const List<String> _feedbackCategories = [
    'content',
    'technical',
    'idea',
    'other',
  ];

  String _categoryLabel(String value, bool zh) => switch ((value, zh)) {
        ('content', true) => '练习内容',
        ('technical', true) => '技术问题',
        ('idea', true) => '功能建议',
        ('other', true) => '其他',
        ('content', false) => 'Practice content',
        ('technical', false) => 'Technical issue',
        ('idea', false) => 'Feature idea',
        _ => 'Other',
      };
}

// Palette shared with Exam details. FAQ and local feedback drafts retain their existing layout.
const _helpBackground = SurgoColors.warmWhite;
const _helpInk = SurgoColors.ink;
const _helpMuted = SurgoColors.muted;
const _helpLine = SurgoColors.line;
const _helpSelected = SurgoColors.yellowTint;
const _helpInfo = SurgoColors.yellowTint;
const _helpRipple = SurgoColors.yellowTint;

class _HelpFaq {
  const _HelpFaq({
    required this.id,
    required this.zhQuestion,
    required this.enQuestion,
    required this.zhAnswer,
    required this.enAnswer,
  });

  final String id;
  final String zhQuestion;
  final String enQuestion;
  final String zhAnswer;
  final String enAnswer;

  String question(bool zh) => zh ? zhQuestion : enQuestion;
  String answer(bool zh) => zh ? zhAnswer : enAnswer;
}

// Capability claims are intentionally narrow and verified against the current
// native sources: exam_selection_page/global_menu/mock_selector for navigation;
// reading_feedback.dart (fixed demo selections), writing review_content.dart
// (fixed ReviewScore), speaking_review_page.dart (fixed review, no audio analysis);
// oral_daily/controller.dart and ielts_mock_speaking/controller.dart (timers);
// auth_form_pages.dart/auth_recovery_pages.dart (local route transitions).
const _helpFaqs = <_HelpFaq>[
  _HelpFaq(
    id: 'start',
    zhQuestion: '如何开始 IELTS 或 TOEFL 练习？',
    enQuestion: 'How do I start IELTS or TOEFL practice?',
    zhAnswer: '在考试选择页选中 IELTS（雅思）或 TOEFL（托福），再点所选卡片的箭头进入首页。选择阅读、听力、写作、口语等科目，按提示选择任务并开始。日常练习也可以从首页的今日训练卡进入。',
    enAnswer: 'On the exam selection page, select IELTS or TOEFL and tap that card’s arrow to enter Home. Choose a subject such as Reading, Listening, Writing or Speaking, then follow its task setup to begin. You can also open daily practice from a Today’s training card on Home.',
  ),
  _HelpFaq(
    id: 'switch-exam',
    zhQuestion: '怎样切换雅思和托福？',
    enQuestion: 'How can I switch between IELTS and TOEFL?',
    zhAnswer: '返回首页，点 SURGO 标识进入考试选择页，选中 IELTS 或 TOEFL 并点卡片箭头确认。也可以在右上角设置菜单的“切换雅思托福”中选择考试类型；切换后会返回首页。建议先结束当前练习再切换。',
    enAnswer: 'Return to Home and tap the SURGO mark to open exam selection. Select IELTS or TOEFL, then confirm with that card’s arrow. You can also use “Exam type” in the top-right settings menu; changing it returns you to Home. Finish your current practice before switching.',
  ),
  _HelpFaq(
    id: 'daily-mock',
    zhQuestion: '日常练习和模拟练习有什么不同？',
    enQuestion: 'What is the difference between daily and mock practice?',
    zhAnswer: '日常练习从首页科目或今日训练进入，适合选择具体任务进行练习。模拟练习从底部中间的黄色考试按钮进入：选择科目，点“Start learning”，阅读说明后启动对应流程。任务顺序、准备时间与作答计时因科目而异；模拟练习不是官方考试。',
    enAnswer: 'Daily practice starts from a subject or Today’s training card on Home and focuses on a selected task. For a mock, tap the yellow center exam button at the bottom, choose a subject, tap “Start learning” and follow its introduction. Task order, preparation time and answer timers vary by subject. Mock practice is not an official exam.',
  ),
  _HelpFaq(
    id: 'grading',
    zhQuestion: '成绩与评语是根据我的作答实时生成的吗？',
    enQuestion: 'Are scores and reviews generated from my answers?',
    zhAnswer: '不一定。当前 IELTS 阅读回顾、写作评分和口语回顾中有固定示例内容，不是对你这次作答的实时自动批改；修改答案后，示例成绩也可能不变。口语回顾没有真实音频分析。请将这些内容用于了解练习和反馈结构，不要作为正式考试成绩或能力评估。',
    enAnswer: 'Not always. The current IELTS reading review, writing scores and speaking review include fixed example content rather than live grading of your attempt. Changing an answer may not change the example result. The speaking review has no real audio analysis. Use these screens to understand the practice and feedback format, not as official scores or an assessment of your ability.',
  ),
  _HelpFaq(
    id: 'recording',
    zhQuestion: '口语练习真的会录音并分析发音吗？',
    enQuestion: 'Does speaking practice record and analyse my voice?',
    zhAnswer: '当前日常口语和 IELTS 口语模拟中的“录音”状态由计时器模拟，不会采集麦克风音频。口语回顾使用示例内容，不会分析你的发音。题干朗读使用设备语音播放，与录制你的声音是不同的功能；请勿把倒计时或波形当作录音已保存的证明。',
    enAnswer: 'The current daily speaking and IELTS mock-speaking “recording” states are timer simulations, not microphone capture. Speaking reviews use example content and do not analyse your pronunciation. Device speech playback can read prompts aloud, but that is separate from recording you. A timer or waveform does not mean your voice has been saved.',
  ),
  _HelpFaq(
    id: 'account',
    zhQuestion: '登录、注册和验证码能用于真实账号吗？',
    enQuestion: 'Do sign-in, registration and codes use a real account?',
    zhAnswer: '当前登录、注册、找回密码和验证码页面是本地原型流程，按钮只在相应页面间切换；它们没有完成真实身份验证、验证码发送或远端账号创建。页面显示的账号信息是示例。请勿在原型中输入真实密码或验证码，也不要把“成功”页面当作账号已受保护的证明。',
    enAnswer: 'The current sign-in, registration, password recovery and code screens are local prototype flows: buttons move between pages rather than authenticating an identity, sending a code or creating a remote account. Displayed account details are examples. Do not enter real passwords or verification codes, or treat a success screen as proof that an account is secured.',
  ),
  _HelpFaq(
    id: 'language',
    zhQuestion: '如何切换中文和英文？',
    enQuestion: 'How do I change the interface language?',
    zhAnswer: '返回首页，打开右上角设置菜单，在“中英切换”中选择“中”或“EN”。帮助页会跟随当前界面语言；练习中的英文题目不一定会随界面语言翻译。',
    enAnswer: 'Return to Home, open the top-right settings menu and choose “中” or “EN” under Language. This help page follows the current interface language. English exercise content does not necessarily translate with the interface.',
  ),
  _HelpFaq(
    id: 'feedback',
    zhQuestion: '怎样保存或分享本页的反馈？',
    enQuestion: 'How can I keep or share my feedback?',
    zhAnswer: '在下方选择类别并填写描述后，可在本地预览中选择并手动复制文本，再粘贴到其他地方保存。本页不会发送给 SURGO，也不会创建工单。离开本页后草稿不保存。',
    enAnswer: 'Choose a category and add a description below. Select and manually copy the local preview text, then paste it elsewhere to keep it. This page does not send feedback to SURGO or create a ticket. Drafts are not saved when you leave.',
  ),
];
