import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:termino/graphql/graphql_config.dart'; // ⚠️ prilagodi ako je druga lokacija

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final client = getGraphQLClient();

    const query = r'''
      query GetReservationsByUser($userId: String!) {
        reservationsByUser(userId: $userId) {
          id
          date
          time
          service {
            name
          }
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {
            'userId': user.uid,
          },
        ),
      );

      if (result.hasException) {
        debugPrint('❌ GraphQL greška: ${result.exception.toString()}');
        return;
      }

      final List data = result.data?['reservationsByUser'] ?? [];

      List<Map<String, dynamic>> temp = [];

      for (var res in data) {
        final rawDate = res['date'];
        DateTime? date;
        if (rawDate is String) {
          date = DateTime.tryParse(rawDate);
        }

        if (date == null) continue;

        temp.add({
          'serviceName': res['service']['name'] ?? 'Nepoznata usluga',
          'date': date,
          'time': res['time'] ?? '',
        });
      }

      setState(() {
        reservations = temp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Neuspjeh pri dohvaćanju rezervacija: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Moji termini', style: TextStyle(color: Color(0xFFC3F44D))),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : reservations.isEmpty
          ? const Center(
        child: Text(
          'Nemate rezerviranih termina.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final res = reservations[index];
          final date = res['date'] as DateTime;

          return Card(
            margin: const EdgeInsets.all(10),
            color: const Color(0xFFC3F44D),
            child: ListTile(
              title: Text(res['serviceName']),
              subtitle: Text(
                '${date.day}.${date.month}.${date.year} u ${res['time']}',
              ),
            ),
          );
        },
      ),
    );
  }
}