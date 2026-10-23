import 'package:flutter/material.dart';
import '../../../../core/tema/tema_lb.dart';
import 'gambar_jaringan.dart';
import 'logo_lb.dart';

class LbHeader extends StatelessWidget {
  final String title;
  const LbHeader({super.key, this.title = 'Beranda'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const LbLogoMark(size: 50),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LASTBITE',
                style: LbText.heading(
                  11,
                  weight: FontWeight.w700,
                  color: LbColors.sageDeep,
                  letterSpacing: 1.6,
                ),
              ),
              Text(
                title,
                style: LbText.heading(27, weight: FontWeight.w700, height: 1.1),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 28,
                  color: LbColors.forest,
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: IgnorePointer(
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: LbColors.peach,
                      shape: BoxShape.circle,
                      border: Border.all(color: LbColors.offWhite, width: 1.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [LbColors.sage, LbColors.sageDeep]),
          ),
          child: ClipOval(
            child: Container(
              color: Colors.white,
              child: const LbNetImage(
                url: 'https://i.pravatar.cc/150?img=32',
                fallbackIcon: Icons.person_rounded,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
