import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'provider_registration_screen.dart';
import 'firestore_service.dart';
import 'provider_details_screen.dart';
import 'main.dart';
import 'register_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initials = name.trim().split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    final isDark = MyApp.of(context)?.isDarkMode ?? false;
    final isGuest = AuthService().isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Dark mode toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => MyApp.of(context)?.toggleTheme(),
            tooltip: isDark ? 'Light mode' : 'Dark mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(name, email, initials),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isGuest) _buildGuestBanner(context),
                  if (isGuest) const SizedBox(height: 16),
                  _buildFavouritesSection(context),
                  const SizedBox(height: 20),
                  _buildMenuCard(context, [
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
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
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ProviderRegistrationScreen())),
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
                  Center(
                    child: Text('Local Service App v1.0.0',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
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
            child: Text(initials,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          const SizedBox(height: 14),
          Text(name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(email,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildGuestBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF9F27)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF633806), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are browsing as a guest',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF633806))),
                Text('Create an account to save your bookings & reviews.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF854F0B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RegisterScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF9F27),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Sign Up',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavouritesSection(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: FirestoreService().getFavourites(),
      builder: (context, snapshot) {
        final favIds = snapshot.data ?? [];
        if (favIds.isEmpty) return const SizedBox.shrink();

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService().getProviders(),
          builder: (context, provSnap) {
            final all = provSnap.data ?? [];
            final favProviders = all
                .where((p) => favIds.contains(p['id'] as String))
                .toList();
            if (favProviders.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Favourites',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    children: favProviders.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      final name = p['name'] as String? ?? '';
                      final initials = name.trim().split(' ').take(2)
                          .map((w) => w[0].toUpperCase()).join();
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE3F2FD),
                              child: Text(initials,
                                  style: const TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ),
                            title: Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(p['service'] as String? ?? ''),
                            trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Color(0xFFAAAAAA)),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProviderDetailsScreen(
                                  provider: {
                                    'id': p['id'] as String,
                                    'name': name,
                                    'exp': p['exp'] as String? ?? 'N/A',
                                    'phone': p['phone'] as String? ?? 'N/A',
                                    'rating': 'New',
                                  },
                                  category: p['service'] as String? ?? '',
                                ),
                              ),
                            ),
                          ),
                          if (i < favProviders.length - 1)
                            const Divider(
                                height: 1,
                                indent: 70,
                                color: Color(0xFFF0F0F0)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
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
                  child: Icon(item.icon, size: 18, color: const Color(0xFF1565C0)),
                ),
                title: Text(item.label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Color(0xFFAAAAAA)),
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 68, color: Color(0xFFF0F0F0)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
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
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Coming soon!')));
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Local Service',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Local Service App',
      children: [
        const SizedBox(height: 12),
        const Text('Find and book trusted local service providers near you.'),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}