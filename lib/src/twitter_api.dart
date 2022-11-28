// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:twitter_api_core/twitter_api_core.dart' as core;

// Project imports:
import 'service/compliance/compliance_service.dart';
import 'service/dms/direct_messages_service.dart';
import 'service/geo/geo_service.dart';
import 'service/lists/lists_service.dart';
import 'service/media/media_service.dart';
import 'service/spaces/spaces_service.dart';
import 'service/tweets/tweets_service.dart';
import 'service/twitter_service.dart';
import 'service/users/users_service.dart';

/// This class represents `Twitter API v2.0`.
///
/// ## Supported Services
///
/// - Tweets service: [tweets]
/// - Users service: [users]
/// - Spaces service: [spaces]
/// - Lists service: [lists]
/// - Media service: [media]
/// - Direct Messages service: [directMessages]
/// - Geo Service: [geo]
/// - Compliance service: [compliance]
///
/// ## Authentication
///
/// An access token generated by [Twitter Developer](https://developer.twitter.com) is required to use
/// the `Twitter API v2.0` endpoint with this object.
///
/// The authentication method supports OAuth 2.0 and OAuth 1.0a.
/// However, please note that if either the Bearer token for OAuth 2.0 or
/// the access token for OAuth 1.0a is not specified, an [ArgumentError] will
/// occur when creating an instance of the [TwitterApi] object.
///
/// You can easily initialize [TwitterApi] object like below:
///
/// ### With OAuth 2.0
///
/// ```dart
/// final twitter = TwitterApi(bearerToken: 'YOUR_TOKEN_HERE');
/// ```
///
/// ### With OAuth 1.0a
///
/// ```dart
/// final twitter = TwitterApi(
///   bearerToken: 'YOUR_TOKEN_HERE',
///   oauthTokens: OAuthTokens(
///     consumerKey: 'YOUR_CONSUMER_KEY_HERE',
///     consumerSecret: 'YOUR_CONSUMER_SECRET_HERE',
///     accessToken: 'YOUR_ACCESS_TOKEN_HERE',
///     accessTokenSecret: 'YOUR_ACCESS_TOKEN_SECRET_HERE',
///   ),
/// );
/// ```
///
/// Then you can access to services and endpoints as you need.
///
/// ```dart
/// final twitter = TwitterApi(bearerToken: 'YOUR_TOKEN_HERE');
///
/// await twitter.tweets.searchRecent(query: '#ElonMusk');
/// ```
///
/// ## User Context
///
/// `Twitter API v2.0` has a detailed `user context` for each endpoint, but
/// you do not need to be aware of the user context when using [TwitterApi].
/// For example, some endpoints can authenticate with either OAuth 2.0 or
/// OAuth 1.0a.
///
/// In such cases, this library authenticates as OAuth 2.0 when
/// only the Bearer token is passed as an argument to the [TwitterApi] object,
/// and authenticates as OAuth 1.0a when the Bearer token and OAuth 1.0a
/// access token are passed at the same time. And endpoints that can only
/// authenticate using the OAuth 2.0 method will authenticate using
/// the Bearer token even if an OAuth 1.0a access token is passed.
///
/// ## App-Only Bearer Token and OAuth 2.0 PKCE
///
/// When authenticating with OAuth 2.0, it is necessary to
/// distinguish between the `Bearer token` generated by the [OAuth 2.0 PKCE](https://developer.twitter.com/en/docs/authentication/oauth-2-0/authorization-code)
/// and the `App-Only Bearer token`. `App-Only bearer token` does **not** have
/// user-specific permissions to operate on content, and therefore cannot be
/// used on some endpoints.
///
/// The specification for obtaining an access token with `OAuth 2.0 PKCE` is
/// not provided in this library. This is because this flow must go through
/// a web browser and requires a dependency on Flutter. Instead, we provide the
/// following separate library that supports access token generation with
/// `OAuth 2.0 PKCE`.
///
/// - [twitter_oauth2_pkce](https://pub.dev/packages/twitter_oauth2_pkce)
///
/// ## Timeout
///
/// When communicating with the `Twitter API v2.0`, network and other
/// infrastructure conditions may inhibit communication, and resulting in
/// inevitable timeouts.
///
/// The timeout period in this library is defined as **10 seconds**,
/// but if you wish to specify an arbitrary timeout period, the following
/// options are available.
///
/// ```dart
/// final twitter = TwitterApi(
///   bearerToken: 'YOUR_TOKEN_HERE',
///   timeout: Duration(seconds: 30),
/// );
/// ```
///
/// ## Exceptions
///
/// The following exceptions may be thrown by this object.
///
/// - [TimeoutException](https://api.dart.dev/stable/2.17.6/dart-async/TimeoutException-class.html): If the request takes longer than the specified timeout.
/// - [UnauthorizedException](https://pub.dev/documentation/twitter_api_core/latest/twitter_api_core/UnauthorizedException-class.html): When the access token is invalid.
/// - [RateLimitExceededException](https://pub.dev/documentation/twitter_api_core/latest/twitter_api_core/RateLimitExceededException-class.html): When the rate limit is exceeded.
/// - [TwitterUploadException](https://pub.dev/documentation/twitter_api_core/latest/twitter_api_core/TwitterUploadException-class.html): When the upload is failed for some reasons.
/// - [DataNotFoundException](https://pub.dev/documentation/twitter_api_core/latest/twitter_api_core/DataNotFoundException-class.html): When response has no body or data field.
/// - [TwitterException](https://pub.dev/documentation/twitter_api_core/latest/twitter_api_core/TwitterException-class.html): When the response body is not a valid JSON and etc.
///
/// ## More Information
///
/// You can see more information from the following links:
///
/// - [Repository](https://github.com/twitter-dart/twitter-api-v2)
/// - [README](https://github.com/twitter-dart/twitter-api-v2/blob/main/README.md)
abstract class TwitterApi {
  /// Returns the new instance of [TwitterApi].
  factory TwitterApi({
    required String bearerToken,
    core.OAuthTokens? oauthTokens,
    Duration timeout = const Duration(seconds: 10),
    core.RetryConfig? retryConfig,
  }) =>
      _TwitterApi(
        bearerToken: bearerToken,
        oauthTokens: oauthTokens,
        timeout: timeout,
        retryConfig: retryConfig,
      );

  /// Returns the tweets service.
  @Deprecated('Use "tweets" property instead. Will be removed in v5.0.0')
  TweetsService get tweetsService;

  /// Returns the users service.
  @Deprecated('Use "users" property instead. Will be removed in v5.0.0')
  UsersService get usersService;

  /// Returns the spaces service.
  @Deprecated('Use "spaces" property instead. Will be removed in v5.0.0')
  SpacesService get spacesService;

  /// Returns the lists service.
  @Deprecated('Use "lists" property instead. Will be removed in v5.0.0')
  ListsService get listsService;

  /// Returns the media service
  @Deprecated('Use "media" property instead. Will be removed in v5.0.0')
  MediaService get mediaService;

  /// Returns the compliance service.
  @Deprecated('Use "compliance" property instead. Will be removed in v5.0.0')
  ComplianceService get complianceService;

  /// Returns the tweets service.
  TweetsService get tweets;

  /// Returns the users service.
  UsersService get users;

  /// Returns the spaces service.
  SpacesService get spaces;

  /// Returns the lists service.
  ListsService get lists;

  /// Returns the media service
  MediaService get media;

  /// Returns the direct messages service.
  DirectMessagesService get directMessages;

  /// Returns the geo service.
  GeoService get geo;

  /// Returns the compliance service.
  ComplianceService get compliance;
}

class _TwitterApi implements TwitterApi {
  _TwitterApi({
    required String bearerToken,
    core.OAuthTokens? oauthTokens,
    required Duration timeout,
    core.RetryConfig? retryConfig,
  }) : _twitterService = TwitterService(
          context: core.ClientContext(
            bearerToken: bearerToken,
            oauthTokens: oauthTokens,
            timeout: timeout,
            retryConfig: retryConfig,
          ),
        ) {
    if (bearerToken.isEmpty && oauthTokens == null) {
      throw ArgumentError(
        'An access token using OAuth 2.0 or OAuth 1.0a is required.',
      );
    }
  }

  /// The twitter service
  final TwitterService _twitterService;

  @override
  TweetsService get tweetsService => _twitterService.tweetsService;

  @override
  UsersService get usersService => _twitterService.usersService;

  @override
  SpacesService get spacesService => _twitterService.spacesService;

  @override
  ListsService get listsService => _twitterService.listsService;

  @override
  MediaService get mediaService => _twitterService.mediaService;

  @override
  ComplianceService get complianceService => _twitterService.complianceService;

  @override
  TweetsService get tweets => _twitterService.tweetsService;

  @override
  UsersService get users => _twitterService.usersService;

  @override
  SpacesService get spaces => _twitterService.spacesService;

  @override
  ListsService get lists => _twitterService.listsService;

  @override
  MediaService get media => _twitterService.mediaService;

  @override
  DirectMessagesService get directMessages =>
      _twitterService.directMessagesService;

  @override
  GeoService get geo => _twitterService.geoService;

  @override
  ComplianceService get compliance => _twitterService.complianceService;
}
