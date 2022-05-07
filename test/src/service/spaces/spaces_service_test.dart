// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:twitter_api_v2/src/client/client_context.dart';
import 'package:twitter_api_v2/src/client/user_context.dart';
import 'package:twitter_api_v2/src/service/spaces/spaces_service.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import '../../../mocks/client_context_stubs.dart' as context;

void main() {
  group('.search', () {
    test('normal case', () async {
      final spacesService = SpacesService(
        context: context.buildGetStub(
          UserContext.oauth2AppOnly,
          '/2/spaces/search',
          'test/src/service/spaces/data/search.json',
          {'query': 'Hello, World!'},
        ),
      );

      final response = await spacesService.search(query: 'Hello, World!');

      expect(response, isA<TwitterResponse>());
      expect(response.data, isA<List<SpaceData>>());
      expect(response.meta, isA<SpaceMeta>());
      expect(response.data.length, 2);
      expect(response.data.first.id, '1DXxyRYNejbKM');
      expect(response.data.first.state, SpaceState.live);
      expect(response.data[1].state, SpaceState.scheduled);
      expect(response.meta!.resultCount, 2);
    });

    test('throws TwitterException', () async {
      final spacesService = SpacesService(
        context: ClientContext(bearerToken: ''),
      );

      expect(
        () async => await spacesService.search(query: 'Throw TwitterException'),
        throwsA(
          allOf(isA<TwitterException>(),
              predicate((e) => e.toString().isNotEmpty)),
        ),
      );
    });

    test('throws TwitterException due to no data', () async {
      final spacesService = SpacesService(
        context: context.buildGetStub(
          UserContext.oauth2AppOnly,
          '/2/spaces/search',
          'test/src/service/spaces/data/no_data.json',
          {'query': 'Throw TwitterException'},
        ),
      );

      expect(
        () async => await spacesService.search(query: 'Throw TwitterException'),
        throwsA(
          allOf(isA<TwitterException>(),
              predicate((e) => e.toString().isNotEmpty)),
        ),
      );
    });

    test('with OAuth1.0a', () async {
      final clientContext = context.buildGetStub(
        UserContext.oauth2AppOnly,
        '/2/spaces/search',
        'test/src/service/spaces/data/search.json',
        {'query': 'Hello, World!'},
      );

      when(clientContext.hasOAuth1Client).thenReturn(true);

      final spacesService = SpacesService(context: clientContext);
      final response = await spacesService.search(query: 'Hello, World!');

      expect(response, isA<TwitterResponse>());
      expect(response.data, isA<List<SpaceData>>());
      expect(response.meta, isA<SpaceMeta>());
      expect(response.data.length, 2);
      expect(response.data.first.id, '1DXxyRYNejbKM');
      expect(response.data.first.state, SpaceState.live);
      expect(response.data[1].state, SpaceState.scheduled);
      expect(response.meta!.resultCount, 2);
    });
  });

  test('.lookupById', () async {
    final spacesService = SpacesService(
      context: context.buildGetStub(
        UserContext.oauth2,
        '/2/spaces/2222',
        'test/src/service/spaces/data/lookup_by_id.json',
        {},
      ),
    );

    final response = await spacesService.lookupById(spaceId: '2222');

    expect(response, isA<TwitterResponse>());
    expect(response.data, isA<SpaceData>());
    expect(response.data.id, '1DXxyRYNejbKM');
    expect(response.data.state, SpaceState.live);
  });

  test('.lookupByIds', () async {
    final spacesService = SpacesService(
      context: context.buildGetStub(
        UserContext.oauth2,
        '/2/spaces',
        'test/src/service/spaces/data/lookup_by_ids.json',
        {'ids': '1DXxyRYNejbKM,2DXxyRYNejbKM'},
      ),
    );

    final response = await spacesService.lookupByIds(
      spaceIds: ['1DXxyRYNejbKM', '2DXxyRYNejbKM'],
    );

    expect(response, isA<TwitterResponse>());
    expect(response.data, isA<List<SpaceData>>());
    expect(response.data.first.id, '1DXxyRYNejbKM');
    expect(response.data.first.state, SpaceState.live);
  });

  test('.lookupBuyers', () async {
    final spacesService = SpacesService(
      context: context.buildGetStub(
        UserContext.oauth2,
        '/2/spaces/2222/buyers',
        'test/src/service/spaces/data/lookup_buyers.json',
        {},
      ),
    );

    final response = await spacesService.lookupBuyers(spaceId: '2222');

    expect(response, isA<TwitterResponse>());
    expect(response.data, isA<List<UserData>>());
    expect(response.data.length, 2);
  });

  test('.lookupTweets', () async {
    final spacesService = SpacesService(
      context: context.buildGetStub(
        UserContext.oauth2,
        '/2/spaces/2222/tweets',
        'test/src/service/spaces/data/lookup_tweets.json',
        {},
      ),
    );

    final response = await spacesService.lookupTweets(spaceId: '2222');

    expect(response, isA<TwitterResponse>());
    expect(response.data, isA<List<TweetData>>());
    expect(response.meta, isA<TweetMeta>());
    expect(response.data.length, 3);
    expect(response.meta!.resultCount, 3);
  });

  test('.lookupByCreatorIds', () async {
    final spacesService = SpacesService(
      context: context.buildGetStub(
        UserContext.oauth2,
        '/2/spaces',
        'test/src/service/spaces/data/lookup_by_creator_ids.json',
        {'user_ids': '1DXxyRYNejbKM,2DXxyRYNejbKM'},
      ),
    );

    final response = await spacesService.lookupByCreatorIds(
      userIds: ['1DXxyRYNejbKM', '2DXxyRYNejbKM'],
    );

    expect(response, isA<TwitterResponse>());
    expect(response.data, isA<List<SpaceData>>());
    expect(response.meta, isA<SpaceMeta>());
    expect(response.data.length, 2);
    expect(response.meta!.resultCount, 2);
  });
}
