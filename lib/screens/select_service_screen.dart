import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:termino/graphql/graphql_config.dart';
import 'reservation_date_screen.dart';

class SelectServiceScreen extends StatelessWidget {
  const SelectServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null || args['providerId'] == null) {
      return const Scaffold(
        body: Center(child: Text('Greška: Pružatelj nije pronađen')),
      );
    }

    final String providerId = args['providerId'];
    final String providerName = args['providerName'] ?? 'Pružatelj';

    final client = getGraphQLClient();

    const String query = r'''
      query GetServices($adminId: String!) {
        servicesByAdmin(adminId: $adminId) {
          id
          name
          duration
        }
      }
    ''';

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: Text('Usluge: $providerName', style: const TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: FutureBuilder<QueryResult>(
        future: client.query(
          QueryOptions(
            document: gql(query),
            variables: {'adminId': providerId},
          ),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError || snapshot.data == null || snapshot.data!.hasException) {
            return const Center(child: Text('Greška pri dohvaćanju usluga', style: TextStyle(color: Colors.white)));
          }

          final services = snapshot.data!.data?['servicesByAdmin'] as List<dynamic>?;

          if (services == null || services.isEmpty) {
            return const Center(child: Text('Nema dostupnih usluga', style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final name = service['name'] ?? 'Usluga';
              final duration = service['duration'] ?? 60;
              final serviceId = service['id'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFC3F44D),
                child: ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Trajanje: $duration min'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservationDateScreen(
                          serviceId: serviceId,
                          durationMinutes: duration,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}