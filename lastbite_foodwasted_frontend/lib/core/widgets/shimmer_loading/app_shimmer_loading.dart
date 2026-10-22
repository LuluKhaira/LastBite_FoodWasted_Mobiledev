import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class ListShimmerLoading extends StatelessWidget {
  final int count;
  const ListShimmerLoading({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 96, height: 96, borderRadius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 60, height: 18, borderRadius: 20),
                        SizedBox(height: 8),
                        ShimmerBox(width: double.infinity, height: 16),
                        SizedBox(height: 6),
                        ShimmerBox(width: 100, height: 12),
                        SizedBox(height: 8),
                        ShimmerBox(width: 80, height: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const ShimmerBox(width: double.infinity, height: 48, borderRadius: 14),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerBox(width: 120, height: 14),
                  ShimmerBox(width: 40, height: 24, borderRadius: 12),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Expanded(child: ShimmerBox(height: 40, borderRadius: 14)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 40, borderRadius: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}