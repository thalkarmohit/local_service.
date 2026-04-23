import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ─── Collections ──────────────────────────────────────────────────────────
  CollectionReference get _providers => _db.collection('providers');

  CollectionReference get _bookings =>
      _db.collection('users').doc(_userId).collection('bookings');

  // 🔥 NEW: Global bookings collection (for provider notifications later)
  CollectionReference get _allBookings => _db.collection('bookings');

  CollectionReference get _reviews => _db.collection('reviews');

  CollectionReference get _favourites =>
      _db.collection('users').doc(_userId).collection('favourites');

  // ─── Providers ────────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getProviders() {
    return _providers.snapshots().map((snap) => snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList());
  }

  Stream<List<Map<String, dynamic>>> getProvidersByCategory(String category) {
    return _providers
        .where('service', isEqualTo: category)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList());
  }

  Future<void> addProvider({
    required String name,
    required String service,
    required String exp,
    required String phone,
    String? imageUrl,
    String? area,
  }) async {
    await _providers.add({
      'name': name,
      'service': service,
      'exp': exp,
      'phone': phone,
      'totalRating': 0,
      'ratingCount': 0,
      'imageUrl': imageUrl ?? '',
      'area': area ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProviderRating({
    required String providerId,
    required int rating,
  }) async {
    await _providers.doc(providerId).update({
      'totalRating': FieldValue.increment(rating),
      'ratingCount': FieldValue.increment(1),
    });
  }

  // ─── Bookings ─────────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getBookings() {
    if (_userId == null) return Stream.value([]);
    return _bookings
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList());
  }

  // 🔥 UPDATED FUNCTION (IMPORTANT)
  Future<String> addBooking({
    required String providerId, // 🔥 NEW
    required String providerName,
    required String service,
    required String phone,
    required DateTime scheduledDate,
    required String scheduledTime,
  }) async {

    // 👉 1. Save in USER bookings (your current system)
    final userDoc = await _bookings.add({
      'providerId': providerId, // 🔥 NEW
      'providerName': providerName,
      'service': service,
      'phone': phone,
      'bookingDate': FieldValue.serverTimestamp(),
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTime': scheduledTime,
      'status': 'pending',
    });

    // 👉 2. ALSO save in GLOBAL bookings (for provider notifications)
    await _allBookings.add({
      'providerId': providerId,
      'providerName': providerName,
      'service': service,
      'phone': phone,
      'userId': _userId,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTime': scheduledTime,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userDoc.id;
  }

  Future<void> deleteBooking(String bookingId) async {
    await _bookings.doc(bookingId).delete();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookings.doc(bookingId).update({'status': status});
  }

  // ─── Reviews ──────────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getReviews(String providerId) {
    return _reviews
        .where('providerId', isEqualTo: providerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList());
  }

  Future<void> addReview({
    required String providerId,
    required String comment,
    required int rating,
  }) async {
    final user = _auth.currentUser;
    await _reviews.add({
      'providerId': providerId,
      'reviewerName': user?.displayName ?? user?.email ?? 'Anonymous',
      'comment': comment,
      'rating': rating,
      'date': FieldValue.serverTimestamp(),
    });
  }

  // ─── Favourites ───────────────────────────────────────────────────────────
  Stream<List<String>> getFavourites() {
    if (_userId == null) return Stream.value([]);
    return _favourites.snapshots().map((snap) =>
        snap.docs.map((d) => d.id).toList());
  }

  Future<bool> isFavourite(String providerId) async {
    if (_userId == null) return false;
    final doc = await _favourites.doc(providerId).get();
    return doc.exists;
  }

  Future<void> toggleFavourite(String providerId, String providerName) async {
    if (_userId == null) return;
    final doc = await _favourites.doc(providerId).get();
    if (doc.exists) {
      await _favourites.doc(providerId).delete();
    } else {
      await _favourites.doc(providerId).set({'name': providerName});
    }
  }
}