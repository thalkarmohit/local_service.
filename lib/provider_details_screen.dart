import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';
import 'booking_model.dart';
import 'provider_model.dart';

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

  @override
  void initState() {
    super.initState();
    _currentRating = widget.provider['rating'] ?? 'New';
  }

  String get _initials {
    final name = widget.provider['name'] ?? 'U';
    return name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(color: Color(0xFF1565C0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 70),
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.provider['name'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.category,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
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
          _infoRow(
            Icons.star_outline_rounded,
            'Rating',
            _currentRating == 'New' ? 'No ratings yet' : '⭐ $_currentRating',
          ),
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
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF888888))),
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
            const SnackBar(content: Text('Phone number not available')),
          );
          return;
        }
        final uri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open dialer')),
            );
          }
        }
      },
      icon: const Icon(Icons.call_rounded),
      label: const Text('Call Provider'),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showBookingDialog(context),
      icon: const Icon(Icons.calendar_today_rounded),
      label: const Text('Book Service'),
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showRatingDialog(context),
      icon: const Icon(Icons.star_rounded, color: Color(0xFFF9A825)),
      label: const Text(
        'Rate this Provider',
        style: TextStyle(color: Color(0xFF1565C0)),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Booking',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${widget.provider["name"]}'),
            const SizedBox(height: 4),
            Text('Service: ${widget.category}'),
            const SizedBox(height: 4),
            const Text('Status: Pending confirmation'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final box = Hive.box<BookingModel>('bookings');
              await box.add(BookingModel(
                providerName: widget.provider['name'] ?? 'Unknown',
                service: widget.category,
                phone: widget.provider['phone'] ?? 'N/A',
                bookingDate: DateTime.now(),
                status: 'pending',
              ));
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service booked successfully ✅')),
                );
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int _selected = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Rate Provider',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How was your experience with ${widget.provider["name"]}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF888888))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setDialogState(() => _selected = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        star <= _selected
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
              Text(
                _ratingLabel(_selected),
                style: const TextStyle(
                    color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final idStr = widget.provider['id'];
                if (idStr != null) {
                  final box = Hive.box<ProviderModel>('providers');
                  final key = int.tryParse(idStr);
                  if (key != null) {
                    final p = box.get(key);
                    if (p != null) {
                      p.totalRating += _selected;
                      p.ratingCount += 1;
                      await p.save();
                      setState(() => _currentRating = p.displayRating);
                    }
                  }
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thanks for your rating! ⭐')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
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