import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ListShimmer({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar/Thumbnail
          ShimmerBox(
            width: itemHeight,
            height: itemHeight,
            borderRadius: 16,
          ),
          const SizedBox(width: 12),
          // Baris Teks / Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const ShimmerBox(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                const ShimmerBox(width: 120, height: 12),
                const SizedBox(height: 12),
                ShimmerBox(width: 80, height: 16, borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}