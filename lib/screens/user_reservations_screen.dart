import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:termino/graphql/graphql_config.dart';

class ReservationTimeScreen extends StatefulWidget {
  const ReservationTimeScreen({super.key});

  @override
  State<ReservationTimeScreen> createState() => _ReservationTimeScreenState();
}

class _ReservationTimeScreenState extends State<ReservationTimeScreen> {
  String? serviceId;
  DateTime? selectedDate;
  List<String> bookedTimes = [];
  String? workingHours;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    serviceId = args?['serviceId'];
    selectedDate = args?['selectedDate'];
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (serviceId == null || selectedDate == null) return;

    final client = getGraphQLClient();

    final serviceQuery = '''
      query GetService(\$id: ID!) {
        service(id: \$id) {
          workingHours
        }
      }
    ''';

    final reservationsQuery = '''
      query GetReservations(\$serviceId: ID!, \$date: String!) {
        reservationsByServiceAndDate(serviceId: \$serviceId, date: \$date) {
          time
        }
      }
    ''';

    try {
      final serviceResult = await client.query(
        QueryOptions(
          document: gql(serviceQuery),
          variables: {'id': serviceId},
        ),
      );

      final wh = serviceResult.data?['service']?['workingHours'] ?? '9-17';
      setState(() => workingHours = wh);

      final dateStr = selectedDate!.toIso8601String().split('T').first;
      final resResult = await client.query(
        QueryOptions(
          document: gql(reservationsQuery),
          variables: {
            'serviceId': serviceId,
            'date': dateStr,
          },
        ),
      );

      final booked = resResult.data?['reservationsByServiceAndDate'] as List<dynamic>? ?? [];

      setState(() {
        bookedTimes = booked.map((e) => e['time'] as String).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Greška kod dohvaćanja podataka: $e');
      setState(() => isLoading = false);
    }
  }

  List<String> _generateTimeSlots(String workingHours) {
    final parts = workingHours.replaceAll('h', '').split('-');
    final start = int.tryParse(parts[0].trim());
    final end = int.tryParse(parts[1].trim());
    if (start == null || end == null || end <= start) return [];

    return List.generate(end - start, (i) => '${start + i}:00');
  }

  void _bookTime(String time) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || serviceId == null || selectedDate == null) return;

    final client = getGraphQLClient();

    final mutation = '''
      mutation CreateReservation(\$input: ReservationInput!) {
        createReservation(input: \$input) {
          id
        }
      }
    ''';

    final dateStr = selectedDate!.toIso8601String().split('T').first;

    final variables = {
      'input': {
        'userId': user.uid,
        'serviceId': serviceId,
        'date': dateStr,
        'time': time,
      }
    };

    try {
      await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: variables,
        ),
      );

      Navigator.pushNamed(context, '/confirm', arguments: {
        'serviceId': serviceId,
        'selectedDate': selectedDate,
        'selectedTime': time,
      });
    } catch (e) {
      debugPrint('❌ Greška pri rezervaciji: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška pri rezervaciji termina.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || workingHours == null || selectedDate == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A434E),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final timeSlots = _generateTimeSlots(workingHours!);

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Odaberi vrijeme', style: TextStyle(color: Color(0xFFC3F44D))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Dostupni termini za ${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final time = timeSlots[index];
                  final isBooked = bookedTimes.contains(time);

                  return Card(
                    color: isBooked ? Colors.grey.shade700 : Colors.white,
                    child: ListTile(
                      title: Text(
                        'Termin u $time',
                        style: TextStyle(
                          color: isBooked ? Colors.white54 : Colors.black,
                        ),
                      ),
                      enabled: !isBooked,
                      onTap: isBooked ? null : () => _bookTime(time),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}