import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'provider_details_screen.dart';
import 'app_colours.dart';

enum SortOption { newest, highestRated, mostExperienced }

class ServiceListScreen extends StatefulWidget {
  final String category;
  const ServiceListScreen({super.key, required this.category});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortSheet(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getProvidersByCategory(widget.category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var providers = snapshot.data ?? [];

          // Apply search
          if (_searchQuery.isNotEmpty) {
            providers = providers
                .where((p) => (p['name'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
                .toList();
          }

          // Apply sort
          switch (_sortOption) {
            case SortOption.highestRated:
              providers.sort((a, b) {
                final aRating = _avgRating(a);
                final bRating = _avgRating(b);
                return bRating.compareTo(aRating);
              });
              break;
            case SortOption.mostExperienced:
              providers.sort((a, b) {
                final aYears = int.tryParse(
                    (a['exp'] as String).replaceAll(RegExp(r'[^0-9]'), '')) ??
                    0;
                final bYears = int.tryParse(
                    (b['exp'] as String).replaceAll(RegExp(r'[^0-9]'), '')) ??
                    0;
                return bYears.compareTo(aYears);
              });
              break;
            case SortOption.newest:
              break;
          }

          return Column(
            children: [
              Container(
                color: const Color(0xFF1565C0),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.category}s...',
                        hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFFAAAAAA)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFFAAAAAA)),
                          onPressed: () =>
                              setState(() => _searchQuery = ''),
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ],
                ),
              ),
              if (_sortOption != SortOption.newest)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  color: const Color(0xFFE3F2FD),
                  child: Row(
                    children: [
                      const Icon(Icons.sort_rounded,
                          size: 14, color: Color(0xFF1565C0)),
                      const SizedBox(width: 6),
                      Text('Sorted by: ${_sortLabel(_sortOption)}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w500)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _sortOption = SortOption.newest),
                        child: const Text('Clear',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: providers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: providers.length,
                  itemBuilder: (context, index) =>
                      _buildProviderCard(context, providers[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _avgRating(Map<String, dynamic> p) {
    final total = (p['totalRating'] ?? 0) as num;
    final count = (p['ratingCount'] ?? 0) as num;
    if (count == 0) return 0;
    return total / count;
  }

  String _displayRating(Map<String, dynamic> p) {
    final avg = _avgRating(p);
    if (avg == 0) return 'New';
    return avg.toStringAsFixed(1);
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...SortOption.values.map((option) {
              final isSelected = _sortOption == option;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_sortIcon(option),
                    color: isSelected
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFAAAAAA)),
                title: Text(_sortLabel(option),
                    style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFF1565C0)
                            : const Color(0xFF1A1A2E))),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF1565C0))
                    : null,
                onTap: () {
                  setState(() => _sortOption = option);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _sortLabel(SortOption option) {
    switch (option) {
      case SortOption.newest: return 'Newest first';
      case SortOption.highestRated: return 'Highest rated';
      case SortOption.mostExperienced: return 'Most experienced';
    }
  }

  IconData _sortIcon(SortOption option) {
    switch (option) {
      case SortOption.newest: return Icons.access_time_rounded;
      case SortOption.highestRated: return Icons.star_rounded;
      case SortOption.mostExperienced: return Icons.work_history_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No ${widget.category}s found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400)),
          const SizedBox(height: 6),
          Text('Be the first to register as a ${widget.category}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
      BuildContext context, Map<String, dynamic> provider) {
    final name = provider['name'] as String? ?? 'Unknown';
    final initials = name.trim().split(' ').take(2)
        .map((w) => w[0].toUpperCase()).join();
    final rating = _displayRating(provider);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProviderDetailsScreen(
            provider: {
              'id': provider['id'] as String,
              'name': name,
              'exp': provider['exp'] as String? ?? 'N/A',
              'phone': provider['phone'] as String? ?? 'N/A',
              'rating': rating,
            },
            category: widget.category,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Text(initials,
                    style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E))),
                        ),
                        _buildRatingBadge(rating),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.category,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.work_history_outlined,
                                size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                                '${provider['exp'] ?? 'N/A'} experience',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('View',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBadge(String rating) {
    if (rating == 'New') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20)),
        child: const Text('New',
            style: TextStyle(
                fontSize: 11,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w600)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF9A825)),
          const SizedBox(width: 3),
          Text(rating,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF633806))),
        ],
      ),
    );
  }
}