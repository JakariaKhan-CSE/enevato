import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/controller/user/user_controller.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class PortfolioSiteScreen extends StatefulWidget {
  final String siteLabel;
  final String siteParam;

  const PortfolioSiteScreen({
    super.key,
    required this.siteLabel,
    required this.siteParam,
  });

  @override
  State<PortfolioSiteScreen> createState() => _PortfolioSiteScreenState();
}

class _PortfolioSiteScreenState extends State<PortfolioSiteScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadItems() {
    final username = _userController.userAccount['username']?.toString() ??
        _authController.userAccount.value?['username']?.toString() ??
        'Apptionary';
    _userController.fetchPortfolioItemsBySite(
      username: username,
      site: widget.siteParam,
    );
  }

  List<Map<String, dynamic>> _filteredItems() {
    final items = _userController.portfolioSiteItems
        .whereType<Map<String, dynamic>>()
        .toList();
    if (_query.trim().isEmpty) {
      return items;
    }
    final query = _query.toLowerCase();
    return items
        .where((item) =>
            (item['item']?.toString().toLowerCase() ?? '').contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.siteLabel),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search items',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surface,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (_userController.portfolioSiteLoading.value) {
                  return const LoadingShimmer();
                }
                if (_userController.portfolioSiteError.isNotEmpty) {
                  return Center(
                    child: Text(
                      _userController.portfolioSiteError.value,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final items = _filteredItems();
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No items found.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 24,
                    color: colorScheme.onSurface.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final title = item['item']?.toString() ?? 'Item';
                    final price =
                        double.tryParse(item['cost']?.toString() ?? '') ?? 0.0;
                    final sales =
                        int.tryParse(item['sales']?.toString() ?? '') ?? 0;
                    final rating =
                        double.tryParse(item['rating']?.toString() ?? '') ?? 0.0;
                    final thumbnail = item['thumbnail']?.toString() ?? '';
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 56,
                            height: 56,
                            color: colorScheme.surface.withOpacity(0.6),
                            child: thumbnail.isEmpty
                                ? Icon(
                                    Icons.image_not_supported,
                                    color: colorScheme.onSurface.withOpacity(0.4),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: thumbnail,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Icon(
                                      Icons.broken_image,
                                      color: colorScheme.onSurface.withOpacity(0.4),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${price.toStringAsFixed(2)} • $sales sale${sales == 1 ? '' : 's'} • ${rating.toStringAsFixed(2)} stars',
                                style: textTheme.bodySmall?.copyWith(
                                  color:
                                      colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
