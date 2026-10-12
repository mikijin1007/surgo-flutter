import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_state.dart';
import '../../app/routes.dart';
import '../../theme/tokens.dart';
import 'profile_settings_ui.dart';
import 'profile_exam_type_cards.dart';
import 'profile_value_editor.dart';

/// Personal exam details are local user inputs, never automatic grading.
class ProfileExamPage extends StatefulWidget {
  const ProfileExamPage({super.key});
  @override
  State<ProfileExamPage> createState() => _ProfileExamPageState();
}

class _ProfileExamPageState extends State<ProfileExamPage> {
  final current = TextEditingController(),
      target = TextEditingController(),
      date = TextEditingController();
  final drafts = <ExamType, List<String>>{};
  late ExamType exam;
  bool get zh => context.read<AppState>().lang == UiLang.zh;
  double get max => exam == ExamType.ielts ? 9 : 6;
  String tr(String a, String b) => zh ? a : b;
  static String dateText(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  @override
  void initState() {
    super.initState();
    exam = context.read<AppState>().examType;
    load(exam);
  }

  void load(ExamType type) {
    final s = context.read<AppState>().session;
    final d = drafts[type];
    current.text = d?[0] ??
        '${s['profileCurrent-${type.name}'] ?? (type == ExamType.ielts ? 6.3 : 4.5)}';
    target.text = d?[1] ??
        '${s['reportTarget-${type.name}'] ?? (type == ExamType.ielts ? 7.0 : 5.0)}';
    date.text = d?[2] ??
        dateText(s['reportDate-${type.name}'] as DateTime? ??
            DateTime.now().add(const Duration(days: 20)));
  }

  void changeExam(ExamType type) {
    drafts[exam] = [current.text, target.text, date.text];
    setState(() {
      exam = type;
      load(type);
    });
  }

  @override
  void dispose() {
    current.dispose();
    target.dispose();
    date.dispose();
    super.dispose();
  }

  DateTime? parseDate(String text) {
    final s = text.trim();
    final d = DateTime.tryParse(s);
    if (d == null || dateText(d) != s || d.year < 2000 || d.year > 2100) {
      return null;
    }
    return d;
  }

  String? scoreError(String? s, {bool halfStep = false}) {
    final n = double.tryParse(s?.trim() ?? '');
    if (n == null || !n.isFinite || n < 0 || n > max) {
      return tr('请输入 0–${max.toInt()} 之间的分数',
          'Enter a score between 0 and ${max.toInt()}');
    }
    if (halfStep && (n * 2 - (n * 2).round()).abs() > .001) {
      return tr('目标分数请以 0.5 分递增', 'Use 0.5-point steps for your target');
    }
    return null;
  }

  Future<void> editValue(String field) async {
    final isDate = field == 'date';
    final isCurrent = field == 'current';
    final controller = isDate
        ? date
        : isCurrent
            ? current
            : target;
    final title = isDate
        ? tr('考试日期', 'Exam date')
        : isCurrent
            ? tr('当前成绩 / 自评', 'Current / self-reported score')
            : tr('目标分数', 'Target score');
    final result = await showProfileValueEditor(context,
        fieldId: 'profile-exam-$field',
        title: title,
        value: controller.text,
        zh: zh,
        helper: isDate
            ? 'YYYY-MM-DD'
            : isCurrent
                ? tr('请输入 0–${max.toInt()} 之间的分数',
                    'Enter a score between 0 and ${max.toInt()}')
                : tr('以 0.5 分递增', 'Use 0.5-point steps'),
        validator: (value) => isDate
            ? (parseDate(value ?? '') == null
                ? tr('请输入有效日期，如 2026-11-01',
                    'Enter a valid date, e.g. 2026-11-01')
                : null)
            : scoreError(value, halfStep: !isCurrent),
        parseDate: isDate ? parseDate : null);
    if (result != null && mounted) setState(() => controller.text = result);
  }

  Widget valueRow(String field, String label, TextEditingController controller,
          {bool isDate = false}) =>
      ProfileValueRow(
          fieldId: 'profile-exam-$field',
          label: label,
          value: controller.text,
          isDate: isDate,
          editLabel: tr('编辑$label', 'Edit $label'),
          onEdit: () => editValue(field));

  void save() {
    // Editors reject invalid drafts. Recheck here for malformed initial values.
    if (scoreError(current.text) != null) {
      editValue('current');
      return;
    }
    if (scoreError(target.text, halfStep: true) != null) {
      editValue('target');
      return;
    }
    if (parseDate(date.text) == null) {
      editValue('date');
      return;
    }
    final app = context.read<AppState>();
    app.examType = exam;
    app.updateSession({
      'profileCurrent-${exam.name}': double.parse(current.text.trim()),
      'reportTarget-${exam.name}': double.parse(target.text.trim()),
      'reportDate-${exam.name}': parseDate(date.text)!,
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    return ProfileSettingsLayout(
      key: const ValueKey('profile-exam-page'),
      title: tr('考试信息', 'Exam details'),
      backKey: 'profile-exam-back',
      footer: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
              key: const ValueKey('profile-exam-save'),
              onPressed: save,
              style: FilledButton.styleFrom(
                  backgroundColor: SurgoColors.yellow,
                  foregroundColor: SurgoColors.onYellowStrong,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              child: Text(tr('保存设置', 'Save settings'),
                  style: profileHeading(16)))),
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ProfileSettingsCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(tr('备考类型', 'Exam type'), style: profileHeading(17)),
                const SizedBox(height: 12),
                ProfileExamTypeCards(
                    selected: exam, zh: zh, onChanged: changeExam),
                const SizedBox(height: 10),
                Text(
                    tr(
                        exam == ExamType.ielts ? '雅思：9 分制' : '托福：本原型使用 6 分制',
                        exam == ExamType.ielts
                            ? 'IELTS: 9-point scale'
                            : 'TOEFL: this prototype uses a 6-point scale'),
                    style: profileBody.copyWith(color: SurgoColors.muted)),
              ])),
          ProfileSettingsCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text(tr('分数与目标', 'Scores and goal'), style: profileHeading(17)),
                const SizedBox(height: 8),
                valueRow('current', tr('当前成绩 / 自评', 'Current score'), current),
                const Divider(height: 1, color: SurgoColors.line),
                valueRow('target', tr('目标分数', 'Target score'), target),
              ])),
          ProfileSettingsCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text(tr('考试计划', 'Exam plan'), style: profileHeading(17)),
                const SizedBox(height: 8),
                valueRow('date', tr('考试日期', 'Exam date'), date, isDate: true),
              ])),
          Text(
              tr('保存后更新个人中心的成绩、目标和倒计时，并同步本次学情目标。数据只保留在本次使用中，不上传账号；示例成绩不是自动评分。',
                  'Saving updates your profile and the learning goal for this session. Nothing is uploaded to an account. Example scores are not automatic grades.'),
              style:
                  profileBody.copyWith(fontSize: 12, color: SurgoColors.muted)),
        ])
      ],
    );
  }
}
