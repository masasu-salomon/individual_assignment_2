import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_constants.dart';
import '../models/listing.dart';

class MapFocusScreen extends StatelessWidget {
  const MapFocusScreen({super.key, required this.listing});

  final Listing listing;

  Future<void> _openInGoogleMapsApp(Listing listing) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}&travelmode=driving',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
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
    final position = LatLng(listing.latitude, listing.longitude);

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          listing.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId(listing.id),
                position: position,
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
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ElevatedButton.icon(
              onPressed: () => _openInGoogleMapsApp(listing),
              icon: const Icon(Icons.open_in_new, size: 20),
              label: const Text('Open in Google Maps for turn-by-turn'),
              style: ElevatedButton.styleFrom(
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
      ),
    );
  }
}
