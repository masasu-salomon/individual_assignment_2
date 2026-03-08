import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../providers/listings_provider.dart';
import '../listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  static const LatLng _kigaliCenter = LatLng(-1.9536, 30.0606);

  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (!mounted) return;
    setState(() {
      _locationGranted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().allListings;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Map View',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kigaliCenter,
              zoom: 12,
            ),
            markers: listings
                .where((l) => l.latitude != 0 || l.longitude != 0)
                .map((listing) => Marker(
                      markerId: MarkerId(listing.id),
                      position: LatLng(listing.latitude, listing.longitude),
                      infoWindow: InfoWindow(
                        title: listing.name,
                        snippet: listing.category,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListingDetailScreen(listing: listing),
                        ),
                      ),
                    ))
                .toSet(),
            myLocationEnabled: _locationGranted,
            myLocationButtonEnabled: _locationGranted,
          ),
          if (listings.isEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No listings to show. Check your connection if the map is blank.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
