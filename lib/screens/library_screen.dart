import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/story_store.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../widgets/edit_sheet.dart';
import '../widgets/screen_header.dart';

/// Tab 3 · 旅行故事库
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: StoryStore.instance,
      builder: (context, _) {
        final stories = StoryStore.instance.storiesNewestFirst;
        return Column(
          children: [
            ScreenHeader(
              title: '旅行故事库',
              subtitle: '共 ${stories.length} 段旅行记忆 · 轻触卡片可修改',
              icon: Icons.photo_album_outlined,
            ),
            Expanded(
              child: stories.isEmpty
                  ? const _EmptyLibrary()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
                      itemCount: stories.length,
                      itemBuilder: (context, i) => _StoryCard(
                        story: stories[i],
                        index: stories.length - i, // 第几段（按写入顺序）
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final int index;
  const _StoryCard({required this.story, required this.index});

  @override
  Widget build(BuildContext context) {
    final edited = story.updatedAt.difference(story.createdAt).inSeconds > 1;
    return GestureDetector(
      onTap: () => showEditSheet(context, story),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.paperDeep, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'NO.${index.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    fontFamily: kMono,
                    fontSize: 11,
                    letterSpacing: 1,
                    color: AppColors.kodakRed,
                  ),
                ),
                const Spacer(),
                Text(
                  formatDate(story.createdAt),
                  style: const TextStyle(
                    fontFamily: kMono,
                    fontSize: 11,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              story.text,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: kSerif,
                fontSize: 15.5,
                height: 1.65,
                color: AppColors.ink,
              ),
            ),
            if (edited) ...[
              const SizedBox(height: 8),
              Text(
                '· 修改于 ${formatDate(story.updatedAt)}',
                style: const TextStyle(
                  fontFamily: kMono,
                  fontSize: 10.5,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_album_outlined,
              size: 56, color: AppColors.inkSoft.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            '故事库还空着',
            style: TextStyle(
              fontFamily: kSerif,
              fontSize: 18,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '去第一个标签页,写下第一段旅行',
            style: TextStyle(
              fontFamily: kMono,
              fontSize: 12,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
