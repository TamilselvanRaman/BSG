import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProductImageView extends StatelessWidget {
  final String? assetPath;
  final String? imageUrl;
  final double size;
  final BoxFit fit;

  const ProductImageView({
    super.key,
    this.assetPath,
    this.imageUrl,
    this.size = 72,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
        imageWidget = Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                  color: AppColors.reportPrimary,
                ),
              ),
            );
          },
        );
      } else {
        // Local file path
        imageWidget = Image.file(
          File(imageUrl!),
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      imageWidget = Image.asset(
        assetPath!,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      imageWidget = _buildFallback();
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(child: imageWidget),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFF0F4F0),
      child: const Icon(
        Icons.eco_rounded,
        color: AppColors.reportPrimary,
        size: 32,
      ),
    );
  }
}
