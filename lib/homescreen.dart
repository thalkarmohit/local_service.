import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'service_list_screen.dart';
import 'provider_details_screen.dart';
import 'provider_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Plumber', 'icon': Icons.plumbing_rounded},
    {'name': 'Electrician', 'icon': Icons.electrical_services_rounded},
    {'name': 'Doctor', 'icon': Icons.medical_services_rounded},
    {'name': 'Carpenter', 'icon': Icons.handyman_rounded},
    {'name': 'Cleaner', 'icon': Icons.cleaning_services_rounded},
    {'name': 'AC Repair', 'icon': Icons.ac_unit_rounded},
  ];

  static const List<Color> _categoryColors = [
    Color(0xFFE3F2FD),
    Color(0xFFFFF8E1),
    Color(0xFFE8F5E9),
    Color(0xFFFBE9E7),
    Color(0xFFE0F7FA),
    Color(0xFFF3E5F5),
  ];

  static const List<Color> _categoryIconColors = [
    Color(0xFF1565C0),
    Color(0xFFF9A825),
    Color(0xFF2E7D32),
    Color(0xFFBF360C),
    Color(0xFF00838F),
    Color(0xFF6A1B9A),
  ];

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ProviderModel>('providers');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<ProviderModel> providerBox, _) {
        final allProviders = providerBox.values.map((p) => {
          'name': p.name,
          'service': p.service,
          'exp': p.exp,
          'phone': p.phone,
          'id': p.key.toString(),
          'rating': p.displayRating,
        }).toList();

        final filtered = _searchQuery.isEmpty
            ? <Map<String, String>>[]
            : allProviders
            .where((p) =>
        (p['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (p['service'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildSearchBar(),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                _buildSearchResults(filtered)
              else ...[
                SliverToBoxAdapter(child: _buildBanner()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Text(
                      'Our Services',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildCategoryCard(context, index),
                      childCount: _categories.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1565C0),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF1565C0),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'What service do you need today?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F6FB),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search providers or services...',
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFAAAAAA)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFFAAAAAA)),
            onPressed: () => setState(() => _searchQuery = ''),
          )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need a service?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Book trusted professionals near you in minutes.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.home_repair_service_rounded,
              size: 52,
              color: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceListScreen(
            category: _categories[index]['name'] as String,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _categoryColors[index],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _categories[index]['icon'] as IconData,
                size: 28,
                color: _categoryIconColors[index],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _categories[index]['name'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<Map<String, String>> results) {
    if (results.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No providers found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different name or service',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final p = results[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: Text(
                    (p['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  p['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${p["service"]} • ⭐ ${p["rating"] ?? "New"}',
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Color(0xFFAAAAAA)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProviderDetailsScreen(
                      provider: p,
                      category: p['service'] ?? '',
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: results.length,
        ),
      ),
    );
  }
}