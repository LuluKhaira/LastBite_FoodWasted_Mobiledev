import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class GridShimmer extends StatelessWidget {
  final int itemCount;

  const GridShimmer({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: ShimmerBox(
              width: double.infinity,
              borderRadius: 16,
            ),
          ),
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 14),
          SizedBox(height: 6),
          ShimmerBox(width: 80, height: 12),
        ],
      ),
    );
  }
}