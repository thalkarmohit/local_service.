import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'service_list_screen.dart';
import 'provider_details_screen.dart';
import 'app_colours.dart';

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
    return Scaffold(
      backgroundColor: AppColors.bg(context),
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
            _buildSearchResults()
          else ...[
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Our Services',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
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
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: AppColors.blue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.blue,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello 👋',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 2),
              Text('What service do you need today?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search providers...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildBanner() {
    return const SizedBox();
  }

  // 🔥 UPDATED CATEGORY CARD WITH ICON
  Widget _buildCategoryCard(BuildContext context, int index) {
    final category = _categories[index];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceListScreen(
            category: category['name'],
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ✅ ICON (LOGO)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _categoryColors[index],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                category['icon'],
                size: 30,
                color: _categoryIconColors[index],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ TEXT
            Text(
              category['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return const SliverToBoxAdapter(
      child: Center(child: Text("Search Coming Soon")),
    );
  }
}