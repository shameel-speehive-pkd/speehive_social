import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speehive_social/core/utils/extensions.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHighest,
      highlightColor: cs.surfaceContainerHigh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: index.isEven
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
