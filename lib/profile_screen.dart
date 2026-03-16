import 'package:flutter/material.dart';
import 'provider_registration_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, List<Map<String, String>>> providersData;

  const ProfileScreen({super.key, required this.providersData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Column(
        children: [

          const SizedBox(height: 20),

          // Profile Picture
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),

          const SizedBox(height: 10),

          const Text(
            "Guest User",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const Text(
            "guest@email.com",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 30),

          // Options
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Booking History"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help & Support"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {},
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProviderRegistrationScreen(
                      providersData: providersData,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Become a Provider"),
            ),
          ),
        ],
      ),
    );
  }
}
