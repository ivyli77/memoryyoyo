import 'package:flutter/material.dart';
import 'services/story_store.dart';
import 'theme/app_theme.dart';
import 'screens/record_screen.dart';
import 'screens/draw_screen.dart';
import 'screens/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StoryStore.instance.load();
  runApp(const BlindBoxApp());
}

class BlindBoxApp extends StatelessWidget {
  const BlindBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '旅行盲盒',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  // 用 IndexedStack 保留每个 tab 的状态
  final List<Widget> _pages = const [
    RecordScreen(),
    DrawScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.film,
          border: Border(
            top: BorderSide(color: AppColors.filmLight, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.film,
          selectedItemColor: AppColors.warmAmber,
          unselectedItemColor: AppColors.paper.withOpacity(0.45),
          selectedLabelStyle:
              const TextStyle(fontFamily: kMono, fontSize: 11.5),
          unselectedLabelStyle:
              const TextStyle(fontFamily: kMono, fontSize: 11.5),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note_outlined),
              activeIcon: Icon(Icons.edit_note),
              label: '记录',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_movies_outlined),
              activeIcon: Icon(Icons.local_movies),
              label: '抽取',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_album_outlined),
              activeIcon: Icon(Icons.photo_album),
              label: '故事库',
            ),
          ],
        ),
      ),
    );
  }
}
