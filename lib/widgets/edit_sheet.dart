import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/story_store.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

/// 编辑 / 删除一条旅行故事的底部弹层
Future<void> showEditSheet(BuildContext context, Story story) {
  final controller = TextEditingController(text: story.text);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.inkSoft.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                '编辑这段旅行',
                style: TextStyle(
                  fontFamily: kSerif,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '写于 ${formatDate(story.createdAt)}',
                style: const TextStyle(
                  fontFamily: kMono,
                  fontSize: 11.5,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.paperDeep, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: TextField(
                  controller: controller,
                  maxLines: 8,
                  minLines: 4,
                  style: const TextStyle(
                    fontFamily: kSerif,
                    fontSize: 15.5,
                    height: 1.6,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '这段旅行……',
                    hintStyle: TextStyle(color: AppColors.inkSoft),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await _confirmDelete(ctx);
                      if (ok == true) {
                        await StoryStore.instance.remove(story.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('删除'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.stamp,
                      textStyle: const TextStyle(fontFamily: kMono),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('内容不能为空哦')),
                        );
                        return;
                      }
                      await StoryStore.instance.update(story.id, text);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.kodakRed,
                      foregroundColor: AppColors.card,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      textStyle: const TextStyle(
                        fontFamily: kMono,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool?> _confirmDelete(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('删除这段旅行?',
          style: TextStyle(fontFamily: kSerif, color: AppColors.ink)),
      content: const Text('删掉后就找不回来了。',
          style: TextStyle(fontFamily: kMono, fontSize: 13, color: AppColors.inkSoft)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('再想想',
              style: TextStyle(color: AppColors.inkSoft, fontFamily: kMono)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('删除',
              style: TextStyle(color: AppColors.stamp, fontFamily: kMono)),
        ),
      ],
    ),
  );
}
