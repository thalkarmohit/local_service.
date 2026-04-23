import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final Map<String, String> provider;
  final String category;

  const ProviderDetailsScreen({
    super.key,
    required this.provider,
    required this.category,
  });

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  late String _currentRating;

  static const List<String> _timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM',
    '4:00 PM', '5:00 PM', '6:00 PM',
  ];

  String get _providerId =>
      widget.provider['id'] ?? widget.provider['name'] ?? 'unknown';

  String get _initials {
    final name = widget.provider['name'] ?? 'U';
    return name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  void initState() {
    super.initState();
    _currentRating = widget.provider['rating'] ?? 'New';
  }

  Widget _buildAvatar(double radius) {
    final imageUrl = widget.provider['imageUrl'] ?? '';
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.white24,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white24,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 28),
                  _buildCallButton(context),
                  const SizedBox(height: 12),
                  _buildBookButton(context),
                  const SizedBox(height: 12),
                  _buildRateButton(context),
                  const SizedBox(height: 28),
                  _buildReviewsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: const Color(0xFF1565C0),
      foregroundColor: Colors.white,
      actions: [
        StreamBuilder<List<String>>(
          stream: FirestoreService().getFavourites(),
          builder: (context, snapshot) {
            final favs = snapshot.data ?? [];
            final isFav = favs.contains(_providerId);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.red.shade300 : Colors.white,
              ),
              onPressed: () async {
                await FirestoreService().toggleFavourite(
                  _providerId,
                  widget.provider['name'] ?? '',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isFav
                          ? 'Removed from favourites'
                          : 'Added to favourites ❤️'),
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(color: Color(0xFF1565C0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 70),
              _buildAvatar(44),
              const SizedBox(height: 12),
              Text(widget.provider['name'] ?? '',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(widget.category,
                  style: const TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          _infoRow(Icons.work_outline_rounded, 'Experience',
              widget.provider['exp'] ?? 'N/A'),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          _infoRow(Icons.phone_outlined, 'Phone',
              widget.provider['phone'] ?? 'N/A'),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          _infoRow(Icons.star_outline_rounded, 'Rating',
              _currentRating == 'New' ? 'No ratings yet' : '⭐ $_currentRating'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('Service', widget.category, Icons.category_outlined),
        const SizedBox(width: 12),
        _statCard('Status', 'Available', Icons.check_circle_outline_rounded),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1565C0)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFAAAAAA))),
                  Text(value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final phone = widget.provider['phone'] ?? '';
        if (phone.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Phone number not available')));
          return;
        }
        final uri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      icon: const Icon(Icons.call_rounded),
      label: const Text('Call Provider'),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showBookingSheet(context),
      icon: const Icon(Icons.calendar_today_rounded),
      label: const Text('Book Service'),
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showRatingDialog(context),
      icon: const Icon(Icons.star_rounded, color: Color(0xFFF9A825)),
      label: const Text('Rate & Review',
          style: TextStyle(color: Color(0xFF1565C0))),
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ─── Reviews Section ───────────────────────────────────────────────────────
  Widget _buildReviewsSection() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getReviews(_providerId),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reviews (${reviews.length})',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            if (reviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.rate_review_outlined,
                        size: 36, color: Color(0xFFCCCCCC)),
                    SizedBox(height: 8),
                    Text('No reviews yet',
                        style: TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 14)),
                    Text('Be the first to review!',
                        style: TextStyle(
                            color: Color(0xFFCCCCCC), fontSize: 12)),
                  ],
                ),
              )
            else
              ...reviews.map((r) => _buildReviewCard(r)),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    DateTime? date;
    if (review['date'] is Timestamp) {
      date = (review['date'] as Timestamp).toDate();
    }
    final rating = (review['rating'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFE3F2FD),
                    child: Text(
                      (review['reviewerName'] as String? ?? 'U')[0]
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(review['reviewerName'] ?? 'Anonymous',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              Row(
                children: List.generate(
                  5,
                      (i) =>
                      Icon(
                        i < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: const Color(0xFFF9A825),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review['comment'] ?? '',
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.5)),
          const SizedBox(height: 6),
          Text(
            date != null ? DateFormat('d MMM yyyy').format(date) : '',
            style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }

  // ─── Booking Sheet ─────────────────────────────────────────────────────────
  void _showBookingSheet(BuildContext context) {
    DateTime? selectedDate;
    String? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          StatefulBuilder(
            builder: (ctx, setSheetState) =>
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery
                        .of(ctx)
                        .viewInsets
                        .bottom + 24,
                    top: 24,
                    left: 24,
                    right: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Schedule Booking',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 4),
                      Text(
                          'Book ${widget.provider["name"]} for ${widget
                              .category}',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF888888))),
                      const SizedBox(height: 24),
                      const Text('Select Date',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: now.add(const Duration(days: 1)),
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 60)),
                            builder: (context, child) =>
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF1565C0)),
                                  ),
                                  child: child!,
                                ),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: selectedDate != null
                                ? const Color(0xFFE3F2FD)
                                : const Color(0xFFF4F6FB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedDate != null
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFFEEEEEE),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 18,
                                  color: selectedDate != null
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFFAAAAAA)),
                              const SizedBox(width: 12),
                              Text(
                                selectedDate != null
                                    ? DateFormat('EEEE, d MMMM yyyy')
                                    .format(selectedDate!)
                                    : 'Tap to choose a date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selectedDate != null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: selectedDate != null
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFFAAAAAA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Select Time Slot',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _timeSlots.map((slot) {
                          final isSelected = selectedTime == slot;
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedTime = slot),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1565C0)
                                    : const Color(0xFFF4F6FB),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFFEEEEEE),
                                ),
                              ),
                              child: Text(slot,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF555555))),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                          (selectedDate == null || selectedTime == null)
                              ? null
                              : () async {
                            await FirestoreService().addBooking(
                              providerId: _providerId, // ✅ FIX ADDED
                              providerName: widget.provider['name'] ?? 'Unknown',
                              service: widget.category,
                              phone: widget.provider['phone'] ?? 'N/A',
                              scheduledDate: selectedDate!,
                              scheduledTime: selectedTime!,
                            );
                            // Fire notification
                            await NotificationService()
                                .showBookingConfirmation(
                              providerName:
                              widget.provider['name'] ?? 'Provider',
                              service: widget.category,
                              date: DateFormat('d MMM yyyy')
                                  .format(selectedDate!),
                              time: selectedTime!,
                            );

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Booked for ${DateFormat('d MMM').format(
                                        selectedDate!)} at $selectedTime ✅',
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            disabledBackgroundColor: const Color(0xFFCCCCCC),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            selectedDate == null || selectedTime == null
                                ? 'Select date & time to confirm'
                                : 'Confirm Booking',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  // ─── Rating + Review Dialog ────────────────────────────────────────────────
  void _showRatingDialog(BuildContext context) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) =>
          StatefulBuilder(
            builder: (ctx, setDialogState) =>
                AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text('Rate & Review',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'How was your experience with ${widget
                              .provider["name"]}?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFF888888), fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final star = i + 1;
                            return GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedRating = star),
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  star <= selectedRating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 36,
                                  color: const Color(0xFFF9A825),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(_ratingLabel(selectedRating),
                            style: const TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Write your review here...',
                            hintStyle:
                            const TextStyle(color: Color(0xFFAAAAAA)),
                            filled: true,
                            fillColor: const Color(0xFFF4F6FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Color(0xFFEEEEEE)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Color(0xFFEEEEEE)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1565C0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Update rating in Firestore
                        await FirestoreService().updateProviderRating(
                          providerId: _providerId,
                          rating: selectedRating,
                        );

                        // Save review in Firestore
                        if (commentController.text
                            .trim()
                            .isNotEmpty) {
                          await FirestoreService().addReview(
                            providerId: _providerId,
                            comment: commentController.text.trim(),
                            rating: selectedRating,
                          );
                        }

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Thanks for your review! ⭐')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 44)),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
          ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}