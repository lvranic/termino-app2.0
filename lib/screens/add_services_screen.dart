import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:termino/graphql/graphql_config.dart';

class AddServicesScreen extends StatefulWidget {
  const AddServicesScreen({super.key});

  @override
  State<AddServicesScreen> createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends State<AddServicesScreen> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  List<Map<String, dynamic>> services = [];

  final _client = getGraphQLClient();

  void _addService() {
    final name = _serviceNameController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());

    if (name.isEmpty || duration == null || duration <= 0) return;

    setState(() {
      services.add({'name': name, 'duration': duration});
      _serviceNameController.clear();
      _durationController.clear();
    });
  }

  Future<void> _saveServices() async {
    if (services.isEmpty) return;

    const mutation = r'''
      mutation AddService($input: ServiceInput!) {
        addService(input: $input) {
          id
        }
      }
    ''';

    for (var service in services) {
      final result = await _client.mutate(MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'name': service['name'],
            'description': 'Opis nije definiran',
            'address': 'Adresa nije definirana',
            'workingHours': '09:00 - 17:00',
            'adminId': '1', // TODO: zamijeni stvarnim ID-om admina
          },
        },
      ));

      if (result.hasException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: ${result.exception.toString()}')),
        );
        return;
      }
    }

    Navigator.pushReplacementNamed(context, '/admin-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Dodaj usluge', style: TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _serviceNameController,
              decoration: const InputDecoration(
                labelText: 'Naziv usluge',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white24,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Trajanje (min)',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white24,
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addService,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC3F44D)),
              child: const Text('Dodaj uslugu', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final s = services[index];
                  return ListTile(
                    title: Text('${s['name']} - ${s['duration']} min', style: const TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveServices,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC3F44D)),
              child: const Text('Spremi i nastavi', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}