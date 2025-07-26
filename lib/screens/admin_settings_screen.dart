import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:termino/graphql/graphql_config.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingHoursController = TextEditingController();
  DateTime? selectedUnavailableDate;
  bool isLoading = true;

  String? serviceId;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final client = getGraphQLClient();

    const userQuery = r'''
      query GetCurrentUser {
        currentUser {
          id
          name
          phone
          email
          services {
            id
            address
            workingHours
          }
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(userQuery)));

    if (result.hasException) {
      debugPrint(result.exception.toString());
      return;
    }

    final data = result.data?['currentUser'];
    if (data == null) return;

    userId = data['id'];
    _nameController.text = data['name'] ?? '';
    _phoneController.text = data['phone'] ?? '';

    if ((data['services'] as List).isNotEmpty) {
      final service = data['services'][0];
      serviceId = service['id'];
      _addressController.text = service['address'] ?? '';
      _workingHoursController.text = service['workingHours'] ?? '';
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveData() async {
    final client = getGraphQLClient();

    const updateUserMutation = r'''
      mutation UpdateUser($id: ID!, $name: String!, $phone: String!) {
        updateUser(id: $id, name: $name, phone: $phone) {
          id
        }
      }
    ''';

    const updateServiceMutation = r'''
      mutation UpdateService($id: ID!, $address: String!, $workingHours: String!) {
        updateService(id: $id, address: $address, workingHours: $workingHours) {
          id
        }
      }
    ''';

    if (userId != null) {
      await client.mutate(MutationOptions(
        document: gql(updateUserMutation),
        variables: {
          'id': userId,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      ));
    }

    if (serviceId != null) {
      await client.mutate(MutationOptions(
        document: gql(updateServiceMutation),
        variables: {
          'id': serviceId,
          'address': _addressController.text.trim(),
          'workingHours': _workingHoursController.text.trim(),
        },
      ));
    }

    if (selectedUnavailableDate != null && userId != null) {
      const addUnavailableMutation = r'''
        mutation AddUnavailableDay($adminId: ID!, $date: String!) {
          addUnavailableDay(adminId: $adminId, date: $date) {
            id
          }
        }
      ''';

      await client.mutate(MutationOptions(
        document: gql(addUnavailableMutation),
        variables: {
          'adminId': userId,
          'date': selectedUnavailableDate!.toIso8601String(),
        },
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Podaci su ažurirani')),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedUnavailableDate = picked;
      });
    }
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType inputType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC3F44D)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Postavke', style: TextStyle(color: Color(0xFFC3F44D))),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Ime'),
            const SizedBox(height: 20),
            _buildTextField(_phoneController, 'Broj mobitela', inputType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField(_addressController, 'Adresa'),
            const SizedBox(height: 20),
            _buildTextField(_workingHoursController, 'Radno vrijeme (npr. 9-17)'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Dodaj neradni dan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
              ),
            ),
            if (selectedUnavailableDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Odabrano: ${selectedUnavailableDate!.day}.${selectedUnavailableDate!.month}.${selectedUnavailableDate!.year}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
              ),
              child: const Text('Spremi promjene'),
            ),
          ],
        ),
      ),
    );
  }
}