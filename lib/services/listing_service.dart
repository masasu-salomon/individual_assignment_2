import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

/// Service layer for listing CRUD operations.
/// All Firestore access lives here. UI must use [ListingsProvider] only—no direct Firestore in widgets.
class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _listingsCollection = 'listings';

  /// Real-time stream of all listings.
  Stream<List<Listing>> streamListings() {
    return _firestore
        .collection(_listingsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Listing.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Listings created by the given user UID.
  /// Uses only equality on createdBy (no orderBy) so no composite index is required.
  Stream<List<Listing>> streamListingsByUser(String uid) {
    return _firestore
        .collection(_listingsCollection)
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => Listing.fromMap(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  Future<void> createListing(Listing listing) async {
    await _firestore.collection(_listingsCollection).add(listing.toMap());
  }

  Future<void> updateListing(Listing listing) async {
    await _firestore
        .collection(_listingsCollection)
        .doc(listing.id)
        .update(listing.toMap());
  }

  Future<void> deleteListing(String listingId) async {
    await _firestore.collection(_listingsCollection).doc(listingId).delete();
  }

  Future<Listing?> getListing(String id) async {
    final doc = await _firestore.collection(_listingsCollection).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Listing.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
