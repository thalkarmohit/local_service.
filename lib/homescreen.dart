import 'package:flutter/material.dart';
import 'service_list_screen.dart';
import 'provider_details_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'provider_model.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> providersData;

  const HomeScreen({super.key, required this.providersData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ProviderModel>('providers');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<ProviderModel> box, _) {
        final hiveProviders = box.values.toList();
        final providersData = Map<String, List<Map<String, String>>>.from(widget.providersData);

        // Add Hive providers into map
        for (var provider in hiveProviders) {
          if (!providersData.containsKey(provider.service)) {
            providersData[provider.service] = [];
          }

          providersData[provider.service]!.add({
            "name": provider.name,
            "exp": provider.exp,
            "phone": provider.phone,
            "id": provider.key.toString(),
            "rating": provider.averageRating.toStringAsFixed(1),
          });
        }

        final allProviders = providersData.entries
            .expand((entry) => entry.value.map((p) => {
          ...p,
          "service": entry.key,
        }))
            .toList();

        final filtered = allProviders.where((p) {
          final name = (p["name"] ?? "").toLowerCase();
          return name.contains(searchQuery.toLowerCase());
        }).toList();

        final List<Map<String, dynamic>> categories = [
          {"name": "Plumber", "icon": Icons.plumbing},
          {"name": "Electrician", "icon": Icons.electrical_services},
          {"name": "Doctor", "icon": Icons.medical_services},
          {"name": "Carpenter", "icon": Icons.handyman},
          {"name": "Cleaner", "icon": Icons.cleaning_services},
          {"name": "Ac repair", "icon": Icons.ac_unit},
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Local Services"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello 👋",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "What service do you need today?",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 15),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Search providers...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                if (searchQuery.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final provider = filtered[index];

                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(provider["name"]!),
                          subtitle: Text("${provider["service"]!} • ⭐ ${provider["rating"] ?? "4.0"}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProviderDetailsScreen(
                                  provider: provider,
                                  category: provider["service"]!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                else ...[
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: categories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceListScreen(
                                  category: categories[index]["name"],
                                  providersData: providersData,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  categories[index]["icon"],
                                  size: 38,
                                  color: const Color(0xFF1976D2),
                                ),
                                const SizedBox(height: 10),
                                Text(categories[index]["name"]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
