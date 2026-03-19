import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'provider_model.dart';
import 'provider_details_screen.dart';

class ServiceListScreen extends StatefulWidget {
  final String category;

  const ServiceListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ProviderModel>('providers');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<ProviderModel> providerBox, _) {
          final providers = providerBox.values
              .where((p) =>
          p.service.toLowerCase() == widget.category.toLowerCase())
              .toList();

          final filtered = providers.where((p) {
            return p.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Container(
                color: const Color(0xFF1565C0),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
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
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildProviderCard(context, filtered[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No ${widget.category}s found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Be the first to register as a ${widget.category}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, ProviderModel provider) {
    final initials = provider.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProviderDetailsScreen(
            provider: {
              'name': provider.name,
              'exp': provider.exp,
              'phone': provider.phone,
              'id': provider.key.toString(),
              'rating': provider.displayRating,
            },
            category: widget.category,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
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
                          child: Text(
                            provider.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        _buildRatingBadge(provider),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.category,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13),
                    ),
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
                              '${provider.exp} experience',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProviderDetailsScreen(
                                provider: {
                                  'name': provider.name,
                                  'exp': provider.exp,
                                  'phone': provider.phone,
                                  'id': provider.key.toString(),
                                  'rating': provider.displayRating,
                                },
                                category: widget.category,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
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

  Widget _buildRatingBadge(ProviderModel provider) {
    if (provider.ratingCount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'New',
          style: TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w600),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF9A825)),
          const SizedBox(width: 3),
          Text(
            provider.displayRating,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF633806)),
          ),
        ],
      ),
    );
  }
}