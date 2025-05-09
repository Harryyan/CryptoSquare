import 'package:flutter/material.dart';

class ImageUtil {
  /// Loads an image from network with error handling
  /// Falls back to a local placeholder image if the network image fails to load
  static Widget loadImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // If the URL contains placeholder.com, use a local asset instead
        if (imageUrl.contains('placeholder.com')) {
          return Image.asset(
            'assets/images/avatar_placeholder.svg',
            width: width,
            height: height,
            fit: fit,
          );
        }

        // For other errors, use avatar.png as fallback
        return Image.asset(
          'assets/images/avatar.png',
          width: width,
          height: height,
          fit: fit,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          ),
        );
      },
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }

    return imageWidget;
  }
}
