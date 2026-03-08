import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../services/listing_service.dart';

/// State management for listings. All Firestore access goes through [ListingService];
/// UI widgets must use this provider only (no direct Firestore in widgets).
class ListingsProvider with ChangeNotifier {
  final ListingService _listingService = ListingService();

  List<Listing> _allListings = [];
  List<Listing> _myListings = [];
  String? _errorMessage;
  bool _isLoading = true;
  bool _isSaving = false;
  StreamSubscription<List<Listing>>? _allSub;
  StreamSubscription<List<Listing>>? _mySub;

  List<Listing> get allListings => _allListings;
  List<Listing> get myListings => _myListings;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  void startListening({String? userUid}) {
    _allSub?.cancel();
    _mySub?.cancel();
    _allSub = _listingService.streamListings().listen(
      (list) {
        _allListings = list;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
    if (userUid != null && userUid.isNotEmpty) {
      _mySub = _listingService.streamListingsByUser(userUid).listen(
        (list) {
          _myListings = list;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage = e.toString();
          notifyListeners();
        },
      );
    }
  }

  void stopListening() {
    _allSub?.cancel();
    _mySub?.cancel();
    _allSub = null;
    _mySub = null;
  }

  Future<void> createListing(Listing listing) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();
    try {
      await _listingService.createListing(listing);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateListing(Listing listing) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();
    try {
      await _listingService.updateListing(listing);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteListing(String listingId) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();
    try {
      await _listingService.deleteListing(listingId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
