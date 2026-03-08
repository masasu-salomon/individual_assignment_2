import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../add_edit_listing_screen.dart';
import '../listing_detail_screen.dart';

/// Bookmarks tab – shows the user's listings in large detail-style cards.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().myListings;
    final uid = context.watch<AuthProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bookmarks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (uid != null && uid.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditListingScreen(
                    userId: uid,
                    existingListing: null,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: uid == null || uid.isEmpty
          ? const Center(
              child: Text(
                'Sign in to see your bookmarked listings.',
                style: TextStyle(color: AppConstants.textSecondary),
              ),
            )
          : listings.isEmpty
              ? const Center(
                  child: Text(
                    'No bookmarks yet.',
                    style: TextStyle(color: AppConstants.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (context, i) {
                    final listing = listings[i];
                    final provider = context.read<ListingsProvider>();
                    return _BookmarkCard(
                      listing: listing,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListingDetailScreen(listing: listing),
                        ),
                      ),
                      onRate: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListingDetailScreen(listing: listing),
                        ),
                      ),
                      onEdit: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditListingScreen(
                            userId: uid ?? '',
                            existingListing: listing,
                          ),
                        ),
                      ),
                      onDelete: () => _confirmDelete(context, provider, listing),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ListingsProvider provider, Listing listing) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('Remove "${listing.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await provider.deleteListing(listing.id);
    }
  }
}

/// Large card matching the detail design: image placeholder, title, star · category · distance, description, Rate button.
class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.listing,
    required this.onTap,
    required this.onRate,
    required this.onEdit,
    required this.onDelete,
  });

  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onRate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const distanceKm = 0.6;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image placeholder – light gray with mountain/sun icon
            Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    height: 160,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.terrain,
                        size: 56,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: AppConstants.accentYellow),
                      const SizedBox(width: 4),
                      Text(
                        '${listing.category} · ${distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (listing.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      listing.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.accentYellow,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Rate this service'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
