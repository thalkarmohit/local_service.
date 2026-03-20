import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'provider_registration_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initials = name.trim().split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(name, email, initials),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Booking History',
                      onTap: () => _showComingSoon(context),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () => _showComingSoon(context),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => _showComingSoon(context),
                    ),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      onTap: () => _showComingSoon(context),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About App',
                      onTap: () => _showAbout(context),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProviderRegistrationScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.add_business_rounded),
                      label: const Text('Become a Provider'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Local Service App v1.0.0',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String initials) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1565C0),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white24,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon,
                      size: 18, color: const Color(0xFF1565C0)),
                ),
                title: Text(item.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Color(0xFFAAAAAA)),
                onTap: item.onTap,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 1, indent: 68, color: Color(0xFFF0F0F0)),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              // AuthGate will automatically redirect to LoginScreen
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Local Service',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Local Service App',
      children: [
        const SizedBox(height: 12),
        const Text(
            'Find and book trusted local service providers near you.'),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
}