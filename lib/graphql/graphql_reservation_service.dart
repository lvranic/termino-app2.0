import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_config.dart';

Future<List<Map<String, dynamic>>> fetchReservationsForAdmin(String adminId, DateTime date) async {
  final client = getGraphQLClient();

  const query = r'''
    query GetReservations($adminId: ID!, $date: DateTime!) {
      reservations(adminId: $adminId, date: $date) {
        time
        durationMinutes
        service {
          id
        }
      }
    }
  ''';

  final result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: {
        'adminId': adminId,
        'date': date.toIso8601String(),
      },
    ),
  );

  if (result.hasException) {
    print('GraphQL error (fetchReservationsForAdmin): ${result.exception.toString()}');
    return [];
  }

  final List<dynamic> reservations = result.data?['reservations'] ?? [];
  return reservations.cast<Map<String, dynamic>>();
}

Future<void> signUpUserGraphQL({
  required String name,
  required String email,
  required String phone,
  required String role,
}) async {
  final client = getGraphQLClient();

  const mutation = r'''
    mutation AddUser($name: String!, $email: String!, $phone: String!, $role: String!) {
      addUser(name: $name, email: $email, phone: $phone, role: $role) {
        id
        name
        email
      }
    }
  ''';

  final result = await client.mutate(
    MutationOptions(
      document: gql(mutation),
      variables: {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
      },
    ),
  );

  if (result.hasException) {
    throw Exception('Greška pri registraciji: ${result.exception.toString()}');
  }
}

Future<void> saveReservationGraphQL({
  required String userId,
  required String serviceId,
  required String time,
  required int hour,
  required int durationMinutes,
  required DateTime date,
}) async {
  final client = getGraphQLClient();

  const mutation = r'''
    mutation CreateReservation($input: ReservationInput!) {
      createReservation(input: $input) {
        id
      }
    }
  ''';

  final result = await client.mutate(
    MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {
          'userId': userId,
          'serviceId': serviceId,
          'time': time,
          'hour': hour,
          'durationMinutes': durationMinutes,
          'date': date.toIso8601String(),
        },
      },
    ),
  );

  if (result.hasException) {
    throw Exception('Greška pri spremanju rezervacije: ${result.exception.toString()}');
  }
}