import 'package:graphql_flutter/graphql_flutter.dart';

GraphQLClient getGraphQLClient() {
  final httpLink = HttpLink('http://10.0.2.2:5096/graphql'); // Android emulator = 10.0.2.2

  return GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: InMemoryStore()),
  );
}