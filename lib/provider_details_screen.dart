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
  late String currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.provider["rating"] ?? "4.0";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.provider["name"] ?? "Provider"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              widget.provider["name"] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.category,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text("Experience: ${widget.provider["exp"] ?? "N/A"}"),
            const SizedBox(height: 8),
            Text("Rating: ⭐ $currentRating"),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final phone = widget.provider["phone"] ?? "";
                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Phone number not available")),
                  );
                  return;
                }
                final Uri uri = Uri(
                  scheme: "tel",
                  path: phone,
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Could not launch dialer")),
                    );
                  }
                }
              },
              icon: const Icon(Icons.call),
              label: const Text("Call"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Booking"),
                    content: Text("Book ${widget.provider["name"]}?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final box = Hive.box<BookingModel>('bookings');

                          final newBooking = BookingModel(
                            providerName: widget.provider["name"] ?? "Unknown",
                            service: widget.category,
                            phone: widget.provider["phone"] ?? "N/A",
                            bookingDate: DateTime.now(),
                          );

                          await box.add(newBooking);

                          if (context.mounted) {
                            Navigator.pop(context); // Close dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Service booked ✅")),
                            );
                          }
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.book_online),
              label: const Text("Book Service"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.star_border),
              label: const Text("Rate Provider"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    int selectedRating = 5;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text("Rate Service"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Select stars:"),
                              DropdownButton<int>(
                                value: selectedRating,
                                items: [1, 2, 3, 4, 5].map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text("$e Star"),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedRating = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Submit"),
                              onPressed: () async {
                                final providerIdStr = widget.provider["id"];
                                if (providerIdStr != null) {
                                  final box = Hive.box<ProviderModel>('providers');
                                  final int? key = int.tryParse(providerIdStr);
                                  
                                  if (key != null) {
                                    final providerObj = box.get(key);
                                    if (providerObj != null) {
                                      providerObj.totalRating += selectedRating;
                                      providerObj.ratingCount += 1;
                                      await providerObj.save();
                                      
                                      this.setState(() {
                                        currentRating = providerObj.averageRating.toStringAsFixed(1);
                                      });
                                    }
                                  }
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Thank you for your rating!")),
                                  );
                                }
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
