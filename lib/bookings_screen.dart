import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:local_service_app/app_colours.dart';
import 'booking_model.dart';
import 'app_colours.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Confirmed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<BookingModel>('bookings');

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.blue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(filter,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.blue
                                  : Colors.white)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<BookingModel> box, _) {
                var bookings = box.keys
                    .map((k) => MapEntry(k, box.get(k)!))
                    .toList()
                    .reversed
                    .toList();

                if (_selectedFilter != 'All') {
                  bookings = bookings
                      .where((e) =>
                  e.value.status.toLowerCase() ==
                      _selectedFilter.toLowerCase())
                      .toList();
                }

                if (bookings.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) =>
                      _buildBookingCard(context, box, bookings[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? 'No bookings yet'
                : 'No $_selectedFilter bookings',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedFilter == 'All'
                ? 'Your booked services will appear here'
                : 'No bookings with this status',
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
    final bookedOn =
    DateFormat('d MMM yyyy, h:mm a').format(booking.bookingDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
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
                  child: Text(booking.providerName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 12),
            if (booking.scheduledDate != null &&
                booking.scheduledTime != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_rounded,
                        size: 18, color: AppColors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Scheduled for',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.blue)),
                          Text(
                            '${DateFormat('EEEE, d MMMM yyyy').format(booking.scheduledDate!)}  •  ${booking.scheduledTime}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Icon(Icons.category_outlined,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(booking.service,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text('Booked on $bookedOn',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.border(context)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 14, color: AppColors.blue),
                    const SizedBox(width: 6),
                    Text(booking.phone,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.blue,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(context, box, key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.redLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 14, color: AppColors.red),
                        SizedBox(width: 4),
                        Text('Cancel',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.red,
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
        bg = AppColors.greenLight;
        textColor = AppColors.green;
        label = 'Confirmed';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'cancelled':
        bg = AppColors.redLight;
        textColor = AppColors.red;
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = AppColors.orangeLight;
        textColor = AppColors.orange;
        label = 'Pending';
        icon = Icons.schedule_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              backgroundColor: AppColors.red,
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