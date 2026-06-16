String _two(int n) => n.toString().padLeft(2, '0');

/// 2025.05.10
String formatDate(DateTime d) => '${d.year}.${_two(d.month)}.${_two(d.day)}';

/// 2025.05.10 14:08
String formatDateTime(DateTime d) =>
    '${formatDate(d)} ${_two(d.hour)}:${_two(d.minute)}';
