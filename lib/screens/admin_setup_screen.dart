import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:termino/graphql/graphql_config.dart';

class AdminSetupScreen extends StatefulWidget {
  final String adminId;

  const AdminSetupScreen({super.key, required this.adminId});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingHoursController = TextEditingController();

  void _saveService() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final address = _addressController.text.trim();
    final hours = _workingHoursController.text.trim();

    if (name.isEmpty || desc.isEmpty || address.isEmpty || hours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Molimo popunite sva polja')),
      );
      return;
    }

    try {
      final client = getGraphQLClient();

      const mutation = r'''
        mutation AddService(
          $adminId: ID!,
          $name: String!,
          $description: String!,
          $address: String!,
          $workingHours: String!
        ) {
          addService(
            adminId: $adminId,
            name: $name,
            description: $description,
            address: $address,
            workingHours: $workingHours
          ) {
            id
          }
        }
      ''';

      final result = await client.mutate(MutationOptions(
        document: gql(mutation),
        variables: {
          'adminId': widget.adminId,
          'name': name,
          'description': desc,
          'address': address,
          'workingHours': hours,
        },
      ));

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uspješno spremljeno!')),
      );

      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text(
          'Postavljanje usluge',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('Naziv usluge', _nameController),
            const SizedBox(height: 20),
            _buildTextField('Opis usluge', _descController, maxLines: 4),
            const SizedBox(height: 20),
            _buildTextField('Adresa lokacije', _addressController),
            const SizedBox(height: 20),
            _buildTextField('Radno vrijeme (npr. 9-17h)', _workingHoursController),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveService,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                'Spremi uslugu',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Sofadi One',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.white24,
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}