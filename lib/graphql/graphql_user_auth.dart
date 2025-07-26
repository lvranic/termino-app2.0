import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_config.dart';

Future<Map<String, dynamic>?> loginWithGraphQL(String email, String password) async {
  final client = getGraphQLClient();

  const query = r'''
    query Login($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        id
        name
        role
      }
    }
  ''';

  final result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: {
        'email': email,
        'password': password,
      },
      fetchPolicy: FetchPolicy.networkOnly, // izbjegava keširanje prijave
    ),
  );

  if (result.hasException) {
    print('Greška pri prijavi: ${result.exception}');
    return null;
  }

  return result.data?['login'];
}