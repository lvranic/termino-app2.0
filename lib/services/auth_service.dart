import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_config.dart';

Future<void> signUpWithGraphQL({
  required String name,
  required String email,
  required String role,
  required String phone,
}) async {
  final client = getGraphQLClient();

  const mutation = r'''
    mutation AddUser($input: UserInput!) {
      addUser(input: $input) {
        id
      }
    }
  ''';

  final result = await client.mutate(
    MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {
          'name': name,
          'email': email,
          'role': role,
          'phone': phone,
        },
      },
    ),
  );

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }
}