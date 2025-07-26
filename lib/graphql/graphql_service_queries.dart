import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_config.dart';

Future<Map<String, dynamic>?> getServiceWithAdmin(String serviceId) async {
  final client = getGraphQLClient();

  const query = r'''
    query GetService($id: ID!) {
      service(id: $id) {
        id
        name
        durationMinutes
        workingHours
        admin {
          id
          name
        }
      }
    }
  ''';

  final result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: {'id': serviceId},
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  if (result.hasException) {
    print('GraphQL error (getServiceWithAdmin): ${result.exception.toString()}');
    return null;
  }

  return result.data?['service'];
}

Future<List<DateTime>> getUnavailableDates(String adminId) async {
  final client = getGraphQLClient();

  const query = r'''
    query GetUnavailableDates($adminId: ID!) {
      unavailableDays(adminId: $adminId) {
        date
      }
    }
  ''';

  final result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: {'adminId': adminId},
    ),
  );

  if (result.hasException) {
    print('GraphQL error (getUnavailableDates): ${result.exception.toString()}');
    return [];
  }

  final List<dynamic> dates = result.data?['unavailableDays'] ?? [];
  return dates.map((entry) => DateTime.parse(entry['date'])).toList();
}

Future<Map<String, dynamic>?> getServiceById(String serviceId) async {
  final client = getGraphQLClient();

  const query = r'''
    query GetService($id: ID!) {
      service(id: $id) {
        id
        name
        durationMinutes
      }
    }
  ''';

  final result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: {'id': serviceId},
    ),
  );

  if (result.hasException) {
    print('GraphQL error (getServiceById): ${result.exception.toString()}');
    return null;
  }

  return result.data?['service'];
}