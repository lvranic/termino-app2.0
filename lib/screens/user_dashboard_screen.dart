import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:termino/graphql/graphql_config.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _openSelectServiceScreen(String adminId, String adminName) {
    Navigator.pushNamed(
      context,
      '/select-service',
      arguments: {
        'providerId': adminId,
        'providerName': adminName,
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = getGraphQLClient();

    const String query = r'''
      query GetAdmins {
        usersByRole(role: "admin") {
          id
          name
        }
      }
    ''';

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Dobrodošli', style: TextStyle(color: Color(0xFFC3F44D))),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFC3F44D)),
            onPressed: () => Navigator.pushNamed(context, '/user-settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFC3F44D)),
            onPressed: () {
              // TODO: Odjava
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pretraži pružatelje usluga',
                  style: TextStyle(color: Color(0xFFC3F44D), fontSize: 20, fontFamily: 'Sofadi One')),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Upiši ime pružatelja...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Svi pružatelji',
                  style: TextStyle(color: Color(0xFFC3F44D), fontSize: 18, fontFamily: 'Sofadi One')),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: FutureBuilder<QueryResult>(
                  future: client.query(QueryOptions(document: gql(query))),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (snapshot.hasError || snapshot.data == null || snapshot.data!.hasException) {
                      return const Center(
                        child: Text('Greška pri dohvaćanju podataka.', style: TextStyle(color: Colors.white70)),
                      );
                    }

                    final admins = snapshot.data!.data?['usersByRole'] as List<dynamic>?;

                    if (admins == null || admins.isEmpty) {
                      return const Center(
                          child: Text('Nema dostupnih pružatelja.', style: TextStyle(color: Colors.white70)));
                    }

                    final filtered = _searchQuery.isEmpty
                        ? admins
                        : admins.where((a) {
                      final name = (a['name'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                          child: Text('Nema rezultata pretrage.', style: TextStyle(color: Colors.white70)));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final admin = filtered[index];
                        final name = admin['name'] ?? 'Nepoznato';
                        final id = admin['id'];

                        return _ServiceCard(
                          title: name,
                          onTap: () => _openSelectServiceScreen(id, name),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Trending',
                  style: TextStyle(color: Color(0xFFC3F44D), fontSize: 18, fontFamily: 'Sofadi One')),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage('https://placehold.co/60x60'),
                    ),
                    title: Text('Popularni ${index + 1}',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: const Text('Broj rezervacija: 120',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/my-appointments'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC3F44D),
                    foregroundColor: const Color(0xFF1A434E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Rezervirani termini', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ServiceCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store, size: 40, color: Color(0xFFC3F44D)),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFFC3F44D), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}