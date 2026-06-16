import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.camera_roll_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.kodakRed),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: kSerif,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: kMono,
              fontSize: 12,
              color: AppColors.inkSoft,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          const _DashedLine(),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 6.0, gap = 5.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dash,
              height: 1.5,
              margin: const EdgeInsets.only(right: gap),
              color: AppColors.inkSoft.withOpacity(0.35),
            ),
          ),
        );
      },
    );
  }
}
