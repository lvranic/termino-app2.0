import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:termino/graphql/graphql_config.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final client = getGraphQLClient();

    const query = r'''
      query GetUser($id: ID!) {
        user(id: $id) {
          name
          phone
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'id': user.uid},
        ),
      );

      final data = result.data?['user'];
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      }
    } catch (e) {
      debugPrint('❌ Greška kod dohvaćanja korisnika: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Molimo unesite sve podatke.')),
      );
      return;
    }

    setState(() => isSaving = true);

    final client = getGraphQLClient();

    const mutation = r'''
      mutation UpdateUser($id: ID!, $name: String!, $phone: String!) {
        updateUser(id: $id, name: $name, phone: $phone) {
          id
        }
      }
    ''';

    try {
      await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'id': user.uid,
            'name': name,
            'phone': phone,
          },
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Podaci su ažurirani')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('❌ Greška kod spremanja podataka: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greška pri spremanju podataka.')),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        title: const Text('Uredi podatke', style: TextStyle(color: Color(0xFFC3F44D))),
        backgroundColor: const Color(0xFF1A434E),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC3F44D)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ime',
                labelStyle: TextStyle(color: Color(0xFFC3F44D)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC3F44D)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC3F44D)),
                ),
              ),
              style: const TextStyle(color: Color(0xFFC3F44D)),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Broj mobitela',
                labelStyle: TextStyle(color: Color(0xFFC3F44D)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC3F44D)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC3F44D)),
                ),
              ),
              style: const TextStyle(color: Color(0xFFC3F44D)),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Spremi', style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}