import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'booking_model.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<BookingModel>('bookings');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<BookingModel> box, _) {
          if (box.isEmpty) {
            return _buildEmptyState(context);
          }

          final bookings = box.keys
              .map((k) => MapEntry(k, box.get(k)!))
              .toList()
              .reversed
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) =>
                _buildBookingCard(context, box, bookings[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your booked services will appear here',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
      BuildContext context, Box<BookingModel> box, MapEntry entry) {
    final booking = entry.value as BookingModel;
    final key = entry.key;

    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(booking.bookingDate);
    final status = booking.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.providerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    size: 14, color: Color(0xFFAAAAAA)),
                const SizedBox(width: 6),
                Text(booking.service,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF888888))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFFAAAAAA)),
                const SizedBox(width: 6),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF888888))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 14, color: Color(0xFF1565C0)),
                    const SizedBox(width: 6),
                    Text(booking.phone,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(context, box, key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCEBEB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 14, color: Color(0xFFA32D2D)),
                        SizedBox(width: 4),
                        Text('Cancel',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFA32D2D),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'confirmed':
        bg = const Color(0xFFEAF3DE);
        textColor = const Color(0xFF27500A);
        label = 'Confirmed';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'cancelled':
        bg = const Color(0xFFFCEBEB);
        textColor = const Color(0xFFA32D2D);
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = const Color(0xFFFAEEDA);
        textColor = const Color(0xFF633806);
        label = 'Pending';
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, Box<BookingModel> box, dynamic key) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA32D2D),
              minimumSize: const Size(80, 40),
            ),
            onPressed: () async {
              await box.delete(key);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}