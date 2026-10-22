import 'package:flutter/material.dart';
import 'warna_lokal.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  const BaseCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WarnaLokal.border),
      ),
      child: child,
    );
  }
}