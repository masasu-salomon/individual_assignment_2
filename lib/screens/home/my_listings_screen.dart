import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../add_edit_listing_screen.dart';
import '../listing_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final listings = provider.myListings;
    final uid = context.watch<AuthProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Listings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditListingScreen(
                  userId: uid ?? '',
                  existingListing: null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: uid == null || uid.isEmpty
          ? const Center(child: Text('Sign in to manage your listings.'))
          : provider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(provider.errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => provider.clearError(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : provider.isLoading && listings.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : listings.isEmpty
                      ? const Center(child: Text('You haven\'t created any listings yet.'))
                      : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (context, i) {
                    final listing = listings[i];
                    return _MyListingCard(
                      listing: listing,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListingDetailScreen(listing: listing),
                        ),
                      ),
                      onEdit: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditListingScreen(
                            userId: uid,
                            existingListing: listing,
                          ),
                        ),
                      ),
                      onDelete: () => _confirmDelete(context, context.read<ListingsProvider>(), listing),
                    );
                  },
                ),
      floatingActionButton: uid != null && uid.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditListingScreen(
                    userId: uid,
                    existingListing: null,
                  ),
                ),
              ),
              backgroundColor: AppConstants.accentYellow,
              child: const Icon(Icons.add, color: AppConstants.textPrimary),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ListingsProvider provider,
    Listing listing,
  ) async {
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
      try {
        await provider.deleteListing(listing.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted')),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to delete'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }
}

class _MyListingCard extends StatelessWidget {
  const _MyListingCard({
    required this.listing,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const rating = 4.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppConstants.cardBackground,
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listing.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < rating.round() ? Icons.star : Icons.star_border,
                            size: 18,
                            color: AppConstants.accentYellow,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '${listing.category} · ${listing.address}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppConstants.textSecondary),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
