import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';

/// 全局故事仓库：本地永久保存（shared_preferences + JSON）
class StoryStore extends ChangeNotifier {
  StoryStore._();
  static final StoryStore instance = StoryStore._();

  static const String _key = 'travel_stories_v1';
  final List<Story> _stories = []; // 按写入顺序（旧 -> 新）
  final Random _rand = Random();

  /// 写入顺序（旧 -> 新）
  List<Story> get stories => List.unmodifiable(_stories);

  /// 故事库展示用：新 -> 旧
  List<Story> get storiesNewestFirst => _stories.reversed.toList();

  int get count => _stories.length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _stories.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final e in list) {
          _stories.add(Story.fromJson(e as Map<String, dynamic>));
        }
      } catch (_) {
        // 数据损坏时忽略，保持空库而不是崩溃
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_stories.map((e) => e.toJson()).toList()),
    );
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_rand.nextInt(99999)}';

  Future<Story> add(String text) async {
    final now = DateTime.now();
    final story = Story(
      id: _newId(),
      text: text.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _stories.add(story);
    await _persist();
    notifyListeners();
    return story;
  }

  Future<void> update(String id, String text) async {
    final idx = _stories.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _stories[idx].text = text.trim();
    _stories[idx].updatedAt = DateTime.now();
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _stories.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  /// 随机抽取一条；尽量避开上一次抽到的那条
  Story? randomStory({String? excludeId}) {
    if (_stories.isEmpty) return null;
    final pool = excludeId == null
        ? _stories
        : _stories.where((e) => e.id != excludeId).toList();
    final source = pool.isEmpty ? _stories : pool;
    return source[_rand.nextInt(source.length)];
  }
}
