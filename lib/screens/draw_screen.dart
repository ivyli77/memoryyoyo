import 'dart:math';
import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/story_store.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../widgets/edit_sheet.dart';
import '../widgets/screen_header.dart';

/// Tab 2 · 旅行记忆抽取（胶卷转动 → 定格一帧）
class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _reveal;
  late final Animation<double> _spinCurve;
  final Random _rand = Random();

  // 胶片帧尺寸
  static const double frameW = 220;
  static const double frameMargin = 7;
  static const double stepW = frameW + frameMargin * 2;
  static const double viewerHeight = 250;

  List<int> _tones = [];
  int _landingIndex = 0;
  Story? _result;
  String? _lastId;
  bool _spinning = false;
  bool _hasDrawn = false;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600));
    _spinCurve = CurvedAnimation(parent: _spin, curve: Curves.easeOutQuart);
    _reveal = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _spin.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _spinning = false);
        _reveal.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _reveal.dispose();
    super.dispose();
  }

  void _draw() {
    final store = StoryStore.instance;
    if (store.count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('盲盒还是空的,先去写一段旅行吧', style: TextStyle(fontFamily: kMono)),
        ),
      );
      return;
    }
    final picked = store.randomStory(excludeId: _lastId) ?? store.stories.first;
    _lastId = picked.id;

    const reelCount = 28;
    _landingIndex = 20 + _rand.nextInt(4); // 20..23
    _tones = List.generate(reelCount, (_) => _rand.nextInt(4));

    setState(() {
      _result = picked;
      _spinning = true;
      _hasDrawn = true;
    });
    _reveal.value = 0;
    _spin.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenHeader(
          title: '旅行记忆抽取',
          subtitle: '转动胶卷,定格一段旧时光',
          icon: Icons.local_movies_outlined,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _viewer(),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _caption(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _spinning ? null : _draw,
              icon: const Icon(Icons.local_movies, size: 20),
              label: Text(_spinning
                  ? '抽取中…'
                  : (_hasDrawn ? '再抽一段记忆' : '抽一段旅行记忆')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.kodakRed,
                foregroundColor: AppColors.card,
                disabledBackgroundColor:
                    AppColors.kodakRed.withOpacity(0.5),
                disabledForegroundColor: AppColors.card,
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

  // ---- 胶片取景器 ----
  Widget _viewer() {
    return Container(
      height: viewerHeight,
      width: double.infinity,
      color: AppColors.film,
      child: LayoutBuilder(
        builder: (context, c) {
          final viewportW = c.maxWidth;
          final targetOffset =
              _landingIndex * stepW + frameMargin - (viewportW - frameW) / 2;
          return AnimatedBuilder(
            animation: Listenable.merge([_spin, _reveal]),
            builder: (context, _) {
              final offset = _spinCurve.value * targetOffset;
              return Stack(
                children: [
                  // 帧带
                  Positioned.fill(
                    child: ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: Transform.translate(
                          offset: Offset(-offset, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(
                                _tones.isEmpty ? 4 : _tones.length,
                                (i) => _buildFrame(i)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 上下齿孔
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 22,
                    child: CustomPaint(
                      painter: _SprocketPainter(offset),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 22,
                    child: CustomPaint(
                      painter: _SprocketPainter(offset),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // 取景框（定格时高亮）
                  IgnorePointer(
                    child: Center(
                      child: Container(
                        width: frameW + 8,
                        height: viewerHeight - 52,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.warmAmber.withOpacity(
                                _spinning || !_hasDrawn ? 0.0 : 0.85),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFrame(int index) {
    final isLanding = _hasDrawn && index == _landingIndex;
    return Container(
      width: frameW,
      height: viewerHeight - 58,
      margin: const EdgeInsets.symmetric(
          horizontal: frameMargin, vertical: 29),
      decoration: BoxDecoration(
        gradient: _toneGradient(_tones.isEmpty ? 0 : _tones[index % _tones.length]),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: isLanding ? _landingContent() : _fillerContent(index),
    );
  }

  Widget _fillerContent(int index) {
    final icons = [
      Icons.landscape_outlined,
      Icons.wb_sunny_outlined,
      Icons.terrain_outlined,
      Icons.directions_boat_outlined,
      Icons.local_cafe_outlined,
    ];
    return Stack(
      children: [
        Center(
          child: Icon(
            icons[index % icons.length],
            size: 40,
            color: AppColors.card.withOpacity(0.35),
          ),
        ),
        Positioned(
          left: 6,
          bottom: 5,
          child: Text(
            'FR ${(index + 1).toString().padLeft(2, '0')}A',
            style: TextStyle(
              fontFamily: kMono,
              fontSize: 9,
              color: AppColors.card.withOpacity(0.45),
            ),
          ),
        ),
      ],
    );
  }

  // 定格帧：停下后"显影"浮现故事
  Widget _landingContent() {
    final t = _spinning ? 0.0 : Curves.easeOut.transform(_reveal.value);
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: _fillerContent(_landingIndex),
        ),
        Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Container(
            margin: const EdgeInsets.all(7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  _result?.text ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: kSerif,
                    fontSize: 14.5,
                    height: 1.6,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---- 抽取结果说明 / 操作 ----
  Widget _caption() {
    if (!_hasDrawn) {
      return const Text(
        '轻触下方按钮,从盲盒里抽出一段旅行',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: kMono,
          fontSize: 13,
          color: AppColors.inkSoft,
        ),
      );
    }
    if (_spinning) {
      return const Text(
        '胶卷转动中……',
        style: TextStyle(
          fontFamily: kMono,
          fontSize: 13,
          color: AppColors.inkSoft,
          letterSpacing: 1,
        ),
      );
    }
    final s = _result!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'FRAME · ${formatDate(s.createdAt)}',
          style: const TextStyle(
            fontFamily: kMono,
            fontSize: 12,
            color: AppColors.inkSoft,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () async {
            await showEditSheet(context, s);
            if (mounted) setState(() {});
          },
          icon: const Icon(Icons.edit_outlined, size: 17),
          label: const Text('编辑这段'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.teal,
            textStyle: const TextStyle(fontFamily: kMono, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// 4 种做旧色调
LinearGradient _toneGradient(int tone) {
  const tones = [
    [Color(0xFF6B5742), Color(0xFF3E3326)],
    [Color(0xFF5A6157), Color(0xFF333A30)],
    [Color(0xFF7A5A48), Color(0xFF4A3528)],
    [Color(0xFF53606A), Color(0xFF313A42)],
  ];
  final c = tones[tone % tones.length];
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: c,
  );
}

/// 滚动的胶片齿孔
class _SprocketPainter extends CustomPainter {
  final double offset;
  _SprocketPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFEDE3CE);
    const holeW = 13.0, holeH = 10.0, gap = 24.0;
    const step = holeW + gap;
    final start = -(offset % step) - step;
    for (double x = start; x < size.width + step; x += step) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, (size.height - holeH) / 2, holeW, holeH),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SprocketPainter old) => old.offset != offset;
}
