import 'package:graphql_flutter/graphql_flutter.dart';

final HttpLink httpLink = HttpLink('http://10.0.2.2:5096/graphql');

final GraphQLClient client = GraphQLClient(
  link: httpLink,
  cache: GraphQLCache(),
);

Future<String> signUpWithGraphQL({
  required String name,
  required String email,
  required String phone,
  required String role,
}) async {
  const String mutation = r'''
    mutation AddUser($input: UserInput!) {
      addUser(input: $input) {
        id
        name
        email
        phone
        role
      }
    }
  ''';

  final Map<String, dynamic> variables = {
    "input": {
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
    }
  };

  print('>>> Šaljem GraphQL mutation');
  print('Mutation: $mutation');
  print('Varijable: $variables');

  final MutationOptions options = MutationOptions(
    document: gql(mutation),
    variables: variables,
  );

  final QueryResult result = await client.mutate(options);

  if (result.hasException) {
    print('❌ GraphQL greška: ${result.exception.toString()}');
    throw Exception('Greška prilikom registracije: ${result.exception.toString()}');
  }

  final userData = result.data?['addUser'];
  if (userData == null || userData['id'] == null) {
    throw Exception('Greška: Nema ID korisnika u odgovoru.');
  }

  print('✅ Uspješno registriran korisnik s ID: ${userData['id']}');
  return userData['id'];
}