import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:termino/graphql/graphql_reservation_service.dart';
import 'package:termino/graphql/graphql_service_queries.dart';

class ReservationTimeScreen extends StatefulWidget {
  const ReservationTimeScreen({super.key});

  @override
  State<ReservationTimeScreen> createState() => _ReservationTimeScreenState();
}

class _ReservationTimeScreenState extends State<ReservationTimeScreen> {
  late String serviceId;
  late DateTime selectedDate;
  int startHour = 9;
  int endHour = 17;
  int durationMinutes = 60;
  bool isLoading = true;
  Set<int> blockedSlots = {};
  int? selectedHour;
  String adminId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    serviceId = args?['serviceId'];
    selectedDate = args?['selectedDate'];
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final serviceData = await getServiceWithAdmin(serviceId);

      if (serviceData == null) {
        throw Exception('Podaci o usluzi nisu dostupni.');
      }

      final hours = serviceData['workingHours'] ?? '9-17';
      durationMinutes = serviceData['durationMinutes'] ?? 60;
      adminId = serviceData['admin']?['id'] ?? '';

      final parts = hours.replaceAll('h', '').split('-');
      if (parts.length == 2) {
        startHour = int.tryParse(parts[0].trim()) ?? 9;
        endHour = int.tryParse(parts[1].trim()) ?? 17;
      }

      final reservations = await fetchReservationsForAdmin(adminId, selectedDate);

      final blocked = <int>{};
      for (var res in reservations) {
        final hour = res['hour'] as int?;
        final duration = res['durationMinutes'] ?? 60;

        if (hour != null) {
          final blocks = (duration / 60).ceil();
          for (int i = 0; i < blocks; i++) {
            blocked.add(hour + i);
          }
        }
      }

      setState(() {
        blockedSlots = blocked;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Greška: $e');
      setState(() => isLoading = false);
    }
  }

  void _confirmReservation() async {
    if (selectedHour == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await saveReservationGraphQL(
        userId: user.uid,
        serviceId: serviceId,
        date: selectedDate,
        hour: selectedHour!,
        durationMinutes: durationMinutes,
        time: '${selectedHour!}:00',
      );

      Navigator.pushNamed(context, '/confirm', arguments: {
        'serviceId': serviceId,
        'selectedDate': selectedDate,
        'selectedTime': '${selectedHour!}:00',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška prilikom spremanja rezervacije.')),
      );
    }
  }

  bool _isSlotAvailable(int hour) {
    final slotsNeeded = (durationMinutes / 60).ceil();
    for (int i = 0; i < slotsNeeded; i++) {
      if (blockedSlots.contains(hour + i)) return false;
    }
    return hour + slotsNeeded <= endHour;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A434E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

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
              'Dostupni termini za ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: endHour - startHour,
                itemBuilder: (context, index) {
                  final hour = startHour + index;
                  final available = _isSlotAvailable(hour);
                  final isSelected = selectedHour == hour;

                  return Card(
                    color: !available
                        ? Colors.grey.shade700
                        : isSelected
                        ? const Color(0xFFC3F44D)
                        : Colors.white,
                    child: ListTile(
                      title: Text(
                        'Termin u $hour:00',
                        style: TextStyle(
                          color: !available
                              ? Colors.white54
                              : isSelected
                              ? const Color(0xFF1A434E)
                              : Colors.black,
                        ),
                      ),
                      enabled: available,
                      onTap: available ? () => setState(() => selectedHour = hour) : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedHour != null ? _confirmReservation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('Rezerviraj termin'),
            ),
          ],
        ),
      ),
    );
  }
}