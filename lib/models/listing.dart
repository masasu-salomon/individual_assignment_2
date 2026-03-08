/// Model for a service or place listing stored in Firestore.
class Listing {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;

  const Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Listing.fromMap(String id, Map<String, dynamic> map) {
    return Listing(
      id: id,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      address: map['address'] as String? ?? '',
      contactNumber: map['contactNumber'] as String? ?? '',
      description: map['description'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      createdBy: map['createdBy'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
    );
  }

  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Predefined categories for the directory.
class ListingCategory {
  static const String hospital = 'Hospital';
  static const String policeStation = 'Police Station';
  static const String library = 'Library';
  static const String restaurant = 'Restaurant';
  static const String cafe = 'Café';
  static const String park = 'Park';
  static const String touristAttraction = 'Tourist Attraction';
  static const String utilityOffice = 'Utility Office';
  static const String pharmacy = 'Pharmacies';

  static const List<String> all = [
    hospital,
    policeStation,
    library,
    restaurant,
    cafe,
    park,
    touristAttraction,
    utilityOffice,
    pharmacy,
  ];
}
