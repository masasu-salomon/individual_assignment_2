import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_constants.dart';
import '../models/listing.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  /// Launches Google Maps with turn-by-turn directions to the listing location.
  Future<void> _openTurnByTurnDirections(Listing listing) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}&travelmode=driving',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fallback: open Maps with destination only
      final fallback = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${listing.latitude},${listing.longitude}',
      );
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValidCoords = listing.latitude != 0 || listing.longitude != 0;
    const distanceKm = 0.6; // placeholder for design match

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          listing.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image placeholder - grey box with mountain/landscape icon (design)
            Container(
              height: 180,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              ),
              child: const Center(
                child: Icon(
                  Icons.terrain,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
            // Embedded Google Map with marker (assignment requirement)
            if (!hasValidCoords)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No location coordinates for this listing. Map and directions are unavailable.',
                          style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasValidCoords)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Location',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                            ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(listing.latitude, listing.longitude),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(listing.id),
                              position: LatLng(listing.latitude, listing.longitude),
                              infoWindow: InfoWindow(
                                title: listing.name,
                                snippet: listing.address.isNotEmpty
                                    ? listing.address
                                    : '${listing.latitude.toStringAsFixed(5)}, ${listing.longitude.toStringAsFixed(5)}',
                              ),
                            ),
                          },
                          myLocationEnabled: false,
                          zoomControlsEnabled: true,
                          mapToolbarEnabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Content card - white, rounded
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.cardBackground,
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  // Subtitle: star + "Café · 0.6 km"
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 18,
                        color: AppConstants.accentYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${listing.category} · ${distanceKm.toStringAsFixed(1)} km',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  if (listing.address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 18, color: AppConstants.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: const TextStyle(color: AppConstants.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (listing.contactNumber.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: AppConstants.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          listing.contactNumber,
                          style: const TextStyle(color: AppConstants.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  if (listing.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      listing.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textPrimary,
                          ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Yellow "Rate this service" button (design)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rating feature coming soon')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.accentYellow,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Rate this service'),
                    ),
                  ),
                  if (hasValidCoords) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openTurnByTurnDirections(listing),
                        icon: const Icon(Icons.directions, size: 22),
                        label: const Text('Get turn-by-turn directions'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppConstants.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
