import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import '../listing_detail_screen.dart';
import 'map_view_screen.dart';
import 'settings_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Listing> _filterListings(List<Listing> list) {
    var result = list;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((l) => l.name.toLowerCase().contains(query))
          .toList();
    }
    if (_selectedCategory.isNotEmpty) {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final all = provider.allListings;
    final filtered = _filterListings(all);

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _selectedCategory.isEmpty ? 'Kigali City' : _selectedCategory,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MapViewScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen(showBackButton: true)),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedCategory.isEmpty,
                    onSelected: () => setState(() => _selectedCategory = ''),
                  ),
                  ...ListingCategory.all.map((cat) {
                    final count = all.where((l) => l.category == cat).length;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _FilterChip(
                        label: count > 0 ? '$cat $count' : cat,
                        selected: _selectedCategory == cat,
                        onSelected: () => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Search bar - magnifying glass on the right
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search for a service',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: Icon(Icons.search, color: AppConstants.textSecondary),
                ),
              ),
            ),
          ),
          // Section title: "Near You" or "Services"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              _selectedCategory.isEmpty ? 'Near You' : 'Services',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryDark,
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
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
                    : filtered.isEmpty
                        ? const Center(child: Text('No listings found'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final listing = filtered[i];
                              final distanceKm = 0.5 + (i % 3) * 0.3; // placeholder
                              return _ListingCard(
                                listing: listing,
                                distanceKm: distanceKm,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ListingDetailScreen(listing: listing),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    // Selected = light gray bg + dark blue text (per design image)
    return Material(
      color: selected ? AppConstants.chipUnselectedBg : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: AppConstants.primaryDark,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.distanceKm,
    required this.onTap,
  });

  final Listing listing;
  final double distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const rating = 4.0; // placeholder; design shows star ratings
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
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${distanceKm.toStringAsFixed(1)} km',
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
              const Icon(Icons.chevron_right, color: AppConstants.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
