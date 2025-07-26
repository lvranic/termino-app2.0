import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:termino/graphql/graphql_config.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> reservations = [];

  final _client = getGraphQLClient();
  final String _adminId = '1'; // TODO: Zamijeni sa stvarnim prijavljenim ID-om korisnika

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => isLoading = true);

    const servicesQuery = r'''
      query ServicesByAdmin($adminId: String!) {
        servicesByAdmin(adminId: $adminId) {
          id
        }
      }
    ''';

    final serviceResult = await _client.query(QueryOptions(
      document: gql(servicesQuery),
      variables: {'adminId': _adminId},
    ));

    if (serviceResult.hasException) {
      debugPrint('Greška kod dohvaćanja usluga: ${serviceResult.exception}');
      setState(() => isLoading = false);
      return;
    }

    final services = serviceResult.data?['servicesByAdmin'] ?? [];
    final serviceIds = services.map<String>((s) => s['id'].toString()).toList();

    if (serviceIds.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    const reservationsQuery = r'''
      query ReservationsByServiceIds($serviceIds: [String!]!) {
        reservationsByServiceIds(serviceIds: $serviceIds) {
          id
          serviceId
          userId
          time
          date
          status
        }
      }
    ''';

    final reservationsResult = await _client.query(QueryOptions(
      document: gql(reservationsQuery),
      variables: {'serviceIds': serviceIds},
    ));

    if (reservationsResult.hasException) {
      debugPrint('Greška kod rezervacija: ${reservationsResult.exception}');
      setState(() => isLoading = false);
      return;
    }

    final rawReservations = reservationsResult.data?['reservationsByServiceIds'] ?? [];

    List<Map<String, dynamic>> temp = [];

    for (var r in rawReservations) {
      if (r['status'] == 'cancelled') continue;

      final userId = r['userId'];
      final userResult = await _client.query(QueryOptions(
        document: gql(r'''
          query GetUser($id: String!) {
            user(id: $id) {
              name
            }
          }
        '''),
        variables: {'id': userId},
      ));

      final userName = userResult.data?['user']?['name'] ?? 'Nepoznati korisnik';

      temp.add({
        'docId': r['id'],
        'date': DateTime.tryParse(r['date']),
        'time': r['time'],
        'userName': userName,
      });
    }

    setState(() {
      reservations = temp;
      isLoading = false;
    });
  }

  Future<void> _cancelReservation(String docId) async {
    final razlogController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Otkazivanje termina'),
        content: TextField(
          controller: razlogController,
          decoration: const InputDecoration(hintText: 'Unesite razlog otkazivanja'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Otkazi')),
        ],
      ),
    );

    if (confirmed != true || razlogController.text.trim().isEmpty) return;

    const cancelMutation = r'''
      mutation CancelReservation($id: String!, $reason: String!) {
        cancelReservation(id: $id, reason: $reason) {
          id
        }
      }
    ''';

    final result = await _client.mutate(MutationOptions(
      document: gql(cancelMutation),
      variables: {
        'id': docId,
        'reason': razlogController.text.trim(),
      },
    ));

    if (result.hasException) {
      debugPrint('Greška pri otkazivanju: ${result.exception}');
      return;
    }

    setState(() {
      reservations.removeWhere((r) => r['docId'] == docId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Termin otkazan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Rezervirani termini', style: TextStyle(color: Color(0xFFC3F44D))),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFC3F44D)),
            onPressed: () => Navigator.pushNamed(context, '/admin-settings'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : reservations.isEmpty
          ? const Center(child: Text('Nema rezervacija', style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final r = reservations[index];
          final date = r['date'] as DateTime;

          return Card(
            margin: const EdgeInsets.all(10),
            color: const Color(0xFFC3F44D),
            child: ListTile(
              title: Text('${r['userName']} - ${date.day}.${date.month}.${date.year} u ${r['time']}'),
              trailing: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _cancelReservation(r['docId']),
              ),
            ),
          );
        },
      ),
    );
  }
}