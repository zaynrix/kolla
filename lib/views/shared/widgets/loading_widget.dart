import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

class LoadingWidget extends StatelessWidget {
  final bool showSkeleton;
  final int skeletonCount;

  const LoadingWidget({
    super.key,
    this.showSkeleton = false,
    this.skeletonCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (showSkeleton) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skeletonCount,
        itemBuilder: (context, index) => const CardSkeleton(),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lädt...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }
}

