import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/user_badge_controller.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class UserBadgesWidget extends StatefulWidget {
  final String username;

  // Injecting the BadgeController
  final BadgeController badgeController = Get.put(BadgeController());

  UserBadgesWidget({required this.username});

  @override
  State<UserBadgesWidget> createState() => _UserBadgesWidgetState();
}

class _UserBadgesWidgetState extends State<UserBadgesWidget> {
  @override
  void initState() {
    super.initState();
    widget.badgeController.bindToAuth(widget.username);
  }

  @override
  void didUpdateWidget(covariant UserBadgesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      widget.badgeController.bindToAuth(widget.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.badgeController.isLoading.value) {
        return const LoadingShimmer();
      }

      if (widget.badgeController.errorMessage.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              widget.badgeController.errorMessage.value,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      if (widget.badgeController.badges.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No badges available.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        );
      }

      // Display the list of badges
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: widget.badgeController.badges.map((badge) {
          final imageUrl = badge['image']?.toString() ?? '';
          final isSvg = imageUrl.endsWith('.svg');
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl.isNotEmpty)
                  isSvg
                      ? _CachedSvg(
                          url: imageUrl,
                          color: colorScheme,
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 20,
                          width: 20,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              const SizedBox(width: 20, height: 20),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.error,
                            size: 18,
                            color: colorScheme.error,
                          ),
                        )
                else
                  Icon(
                    Icons.verified,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                const SizedBox(width: 6),
                Text(
                  badge['label']?.toString() ?? 'Badge',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}

class _CachedSvg extends StatelessWidget {
  final String url;
  final ColorScheme color;

  const _CachedSvg({required this.url, required this.color});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: DefaultCacheManager().getSingleFile(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(width: 20, height: 20);
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Icon(
            Icons.error,
            size: 18,
            color: color.error,
          );
        }
        return SvgPicture.file(
          snapshot.data!,
          height: 20,
          width: 20,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
