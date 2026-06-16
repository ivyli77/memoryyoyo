import 'package:flutter/material.dart';
import '../services/story_store.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';

/// Tab 1 · 旅行故事记录
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _toast('先写点什么,再投进盲盒吧');
      return;
    }
    setState(() => _saving = true);
    await StoryStore.instance.add(text);
    _controller.clear();
    if (mounted) FocusScope.of(context).unfocus();
    setState(() => _saving = false);
    _toast('已封存进盲盒 · 第 ${StoryStore.instance.count} 段');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: kMono)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenHeader(
          title: '旅行故事记录',
          subtitle: '一句话,或一小段,封存此刻的旅行',
          icon: Icons.edit_note,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
            child: _Postcard(controller: _controller),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.archive_outlined, size: 20),
              label: const Text('投入盲盒'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.kodakRed,
                foregroundColor: AppColors.card,
                textStyle: const TextStyle(
                  fontFamily: kMono,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Postcard extends StatelessWidget {
  final TextEditingController controller;
  const _Postcard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.paperDeep, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'POST · CARD',
                style: TextStyle(
                  fontFamily: kMono,
                  fontSize: 11,
                  letterSpacing: 2,
                  color: AppColors.inkSoft,
                ),
              ),
              // 邮票占位
              Container(
                width: 30,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  border: Border.all(color: AppColors.kodakRed, width: 1.4),
                ),
                child: const Icon(Icons.public,
                    size: 18, color: AppColors.teal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: null,
            minLines: 8,
            style: const TextStyle(
              fontFamily: kSerif,
              fontSize: 16.5,
              height: 1.7,
              color: AppColors.ink,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '那天的光、那段路、那个突然想留下的瞬间……',
              hintStyle: TextStyle(
                fontFamily: kSerif,
                color: AppColors.inkSoft,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
