import 'package:flutter/material.dart';
import 'provider_registration_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Booking History',
                      onTap: () => Navigator.of(context)
                          .pushNamed('/bookings'),
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
                      onPressed: () => _showComingSoon(context),
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

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1565C0),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_rounded, size: 48, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 16, color: Color(0xFF1565C0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Guest User',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'guest@email.com',
            style: TextStyle(color: Colors.white70, fontSize: 13),
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
                  child:
                  Icon(item.icon, size: 18, color: const Color(0xFF1565C0)),
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
            'Find and book trusted local service providers near you — plumbers, electricians, doctors, and more.'),
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