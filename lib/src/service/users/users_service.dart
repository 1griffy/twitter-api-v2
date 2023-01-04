// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:http/http.dart';

// 🌎 Project imports:
import '../../core/adaptor/user_object_adaptor.dart';
import '../../core/client/client_context.dart';
import '../../core/client/user_context.dart';
import '../base_service.dart';
import '../pagination/bidirectional_pagination.dart';
import '../response/twitter_response.dart';
import '../tweets/tweet_field.dart';
import 'user_data.dart';
import 'user_expansion.dart';
import 'user_field.dart';
import 'user_meta.dart';

/// This class provides methods to easily access endpoints based on User.
abstract class UsersService {
  /// Returns the new instance of [UsersService].
  factory UsersService({required ClientContext context}) =>
      _UsersService(context: context);

  /// Allows a user ID to follow another user.
  ///
  /// If the target user does not have public Tweets, this endpoint will send a
  /// follow request.
  ///
  /// The request succeeds with no action when the authenticated user sends
  /// a request to a user they're already following, or if they're sending
  /// a follower request to a user that does not have public Tweets.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The authenticated user ID who you would like to initiate the
  ///             follow on behalf of. You must pass the Access Tokens that
  ///             relate to this user when authenticating the request.
  ///
  /// - [targetUserId]: The user ID of the user that you would like the id to
  ///                   follow.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id/following
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - follows.write
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    50 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/post-users-source_user_id-following
  Future<TwitterResponse<bool, void>> createFollow(
      {required String userId, required String targetUserId});

  /// Allows a user ID to unfollow another user.
  ///
  /// The request succeeds with no action when the authenticated user ends a
  /// request to a user they're not following or have already unfollowed.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID who you would like to initiate the unfollow on
  ///             behalf of. You must pass the Access Tokens that relate to this
  ///             user when authenticating the request.
  ///
  /// - [targetUserId]: The user ID of the user that you would like the user id
  ///                   to unfollow.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:source_user_id/following/:target_user_id
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - follows.write
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    50 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/delete-users-source_id-following
  Future<TwitterResponse<bool, void>> destroyFollow(
      {required String userId, required String targetUserId});

  /// Returns a list of users who are followers of the specified user ID.
  ///
  /// The value returned when the [paging] callback is specified is
  /// the first object obtained that started the paging process. The value
  /// obtained in the paging process is passed to the [paging] callback
  /// function as a `PagingEvent` object.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID whose followers you would like to retrieve.
  ///
  /// - [maxResults]: The maximum number of results to be returned per page.
  ///                 This can be a number between 1 and the 1000. By default,
  ///                 each page will return 100 results.
  ///
  /// - [paginationToken]: Used to request the next page of results if all
  ///                      results weren't returned with the latest request, or
  ///                      to go back to the previous page of results. To return
  ///                      the next page, pass the `next_token` returned
  ///                      in your previous response. To go back one page, pass
  ///                      the `previous_token` returned in your previous
  ///                      response.
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users. The ID that
  ///                 represents the expanded data object will be included
  ///                 directly in the user data object, but the expanded object
  ///                 metadata will be returned within the includes response
  ///                 object, and will also include the ID so that you can match
  ///                 this data object to the original Tweet object.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// - [paging]: If this callback function is specified, paging is
  ///             performed continuously until certain conditions are met.
  ///             This paging function is bi-directional,
  ///             both forward and backward, and allows for safe paging.
  ///             The response and other metadata obtained when paging is
  ///             performed is passed to the callback function as
  ///             `PagingEvent` object. So you can get the result of paging
  ///             from `PagingEvent` object. Also, the direction and continuity
  ///             of paging can be controlled by returning
  ///             `PaginationControl` object in the `paging` callback function.
  ///             Please use `PaginationControl.forward()` to continue paging
  ///             and move forward, or use `PaginationControl.backward()`
  ///             to move backward. And be sure to return
  ///             `PaginationControl.stop()` to terminate paging on
  ///             arbitrary conditions, otherwise paging continues until the
  ///             next page runs out.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id/followers
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 2.0 App-only
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - follows.read
  ///
  /// ## Rate Limits
  ///
  /// - **App rate limit (OAuth 2.0 App Access Token)**:
  ///    15 requests per 15-minute window shared among all users of your app
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    15 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/get-users-id-followers
  Future<TwitterResponse<List<UserData>, UserMeta>> lookupFollowers({
    required String userId,
    int? maxResults,
    String? paginationToken,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
    Paging<List<UserData>, UserMeta>? paging,
  });

  /// Returns a list of users the specified user ID is following.
  ///
  /// The value returned when the [paging] callback is specified is
  /// the first object obtained that started the paging process. The value
  /// obtained in the paging process is passed to the [paging] callback
  /// function as a `PagingEvent` object.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID whose following you would like to retrieve.
  ///
  /// - [maxResults]: The maximum number of results to be returned per page.
  ///                 This can be a number between 1 and the 1000. By default,
  ///                 each page will return 100 results.
  ///
  /// - [paginationToken]: Used to request the next page of results if all
  ///                      results weren't returned with the latest request, or
  ///                      to go back to the previous page of results. To return
  ///                      the next page, pass the `next_token` returned
  ///                      in your previous response. To go back one page, pass
  ///                      the `previous_token` returned in your previous
  ///                      response.
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// - [paging]: If this callback function is specified, paging is
  ///             performed continuously until certain conditions are met.
  ///             This paging function is bi-directional,
  ///             both forward and backward, and allows for safe paging.
  ///             The response and other metadata obtained when paging is
  ///             performed is passed to the callback function as
  ///             `PagingEvent` object. So you can get the result of paging
  ///             from `PagingEvent` object. Also, the direction and continuity
  ///             of paging can be controlled by returning
  ///             `PaginationControl` object in the `paging` callback function.
  ///             Please use `PaginationControl.forward()` to continue paging
  ///             and move forward, or use `PaginationControl.backward()`
  ///             to move backward. And be sure to return
  ///             `PaginationControl.stop()` to terminate paging on
  ///             arbitrary conditions, otherwise paging continues until the
  ///             next page runs out.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id/following
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 2.0 App-only
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - follows.read
  ///
  /// ## Rate Limits
  ///
  /// - **App rate limit (OAuth 2.0 App Access Token):
  ///    15 requests per 15-minute window shared among all users of your app
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    15 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/get-users-id-following
  Future<TwitterResponse<List<UserData>, UserMeta>> lookupFollowings({
    required String userId,
    int? maxResults,
    String? paginationToken,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
    Paging<List<UserData>, UserMeta>? paging,
  });

  /// Returns a variety of information about a single user specified by the
  /// requested ID.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The ID of the user to lookup.
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users. The ID that
  ///                 represents the expanded data object will be included
  ///                 directly in the user data object, but the expanded object
  ///                 metadata will be returned within the includes response
  ///                 object, and will also include the ID so that you can match
  ///                 this data object to the original Tweet object.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 2.0 App-only
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  ///
  /// ## Rate Limits
  ///
  /// - **App rate limit (OAuth 2.0 App Access Token)**:
  ///    900 requests per 15-minute window shared among all users of your app
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    900 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/lookup/api-reference/get-users-id
  Future<TwitterResponse<UserData, void>> lookupById({
    required String userId,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  });

  /// Returns a variety of information about one or more users specified by the
  /// requested IDs.
  ///
  /// ## Parameters
  ///
  /// - [userIds]: 	A list of user IDs.
  ///               Up to 100 are allowed in a single request.
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users. The ID that
  ///                 represents the expanded data object will be included
  ///                 directly in the user data object, but the expanded object
  ///                 metadata will be returned within the includes response
  ///                 object, and will also include the ID so that you can match
  ///                 this data object to the original Tweet object.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 2.0 App-only
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  ///
  /// ## Rate Limits
  ///
  /// - **App rate limit (OAuth 2.0 App Access Token)**:
  ///    900 requests per 15-minute window shared among all users of your app
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    900 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/lookup/api-reference/get-users
  Future<TwitterResponse<List<UserData>, void>> lookupByIds({
    required List<String> userIds,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  });

  /// Returns a variety of information about one or more users specified by
  /// their usernames.
  ///
  /// ## Parameters
  ///
  /// - [username]: The Twitter username (handle) of the user.
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users. The ID that
  ///                 represents the expanded data object will be included
  ///                 directly in the user data object, but the expanded object
  ///                 metadata will be returned within the includes response
  ///                 object, and will also include the ID so that you can match
  ///                 this data object to the original Tweet object.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/by/username/:username
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 2.0 App-only
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  ///
  /// ## Rate Limits
  ///
  /// - **App rate limit (OAuth 2.0 App Access Token)**:
  ///    900 requests per 15-minute window shared among all users of your app
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    900 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/lookup/api-reference/get-users-by-username-username
  Future<TwitterResponse<UserData, void>> lookupByName({
    required String username,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  });

  /// Returns a variety of information about one or more users specified by
  /// their usernames.
  ///
  /// ## Parameters
  ///
  /// - [usernames]: A list of Twitter usernames (handles).
  ///                Up to 100 are allowed in a single request.
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users. The ID that
  ///                 represents the expanded data object will be included
  ///                 directly in the user data object, but the expanded object
  ///                 metadata will be returned within the includes response
  ///                 object, and will also include the ID so that you can match
  ///                 this data object to the original Tweet object.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/by
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 2.0 App-only
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  ///
  /// ## Rate Limits
  ///
  /// - **App rate limit (OAuth 2.0 App Access Token)**:
  ///    900 requests per 15-minute window shared among all users of your app
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    900 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/lookup/api-reference/get-users-by
  Future<TwitterResponse<List<UserData>, void>> lookupByNames({
    required List<String> usernames,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  });

  /// Returns information about an authorized user.
  ///
  /// ## Parameters
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users. The ID that
  ///                 represents the expanded data object will be included
  ///                 directly in the user data object, but the expanded object
  ///                 metadata will be returned within the includes response
  ///                 object, and will also include the ID so that you can match
  ///                 this data object to the original Tweet object.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/me
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///     75 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/lookup/api-reference/get-users-me
  Future<TwitterResponse<UserData, void>> lookupMe({
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  });

  /// Allows an authenticated user ID to mute the target user.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID who you would like to initiate the mute on behalf
  ///             of. It must match your own user ID or that of an
  ///             authenticating user, meaning that you must pass the Access
  ///             Tokens associated with the user ID when authenticating your
  ///             request.
  ///
  /// - [targetUserId]: The user ID of the user that you would like the id to
  ///                   mute. The body should contain a string of the user ID
  ///                   inside of a JSON object.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id/muting
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - mute.write
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    50 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/mutes/api-reference/post-users-user_id-muting
  Future<TwitterResponse<bool, void>> createMute(
      {required String userId, required String targetUserId});

  /// Allows an authenticated user ID to unmute the target user.
  ///
  /// The request succeeds with no action when the user sends a request to a
  /// user they're not muting or have already unmuted.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID who you would like to initiate an unmute on
  ///             behalf of. The user’s ID must correspond to the user ID of the
  ///             authenticating user, meaning that you must pass the Access
  ///             Tokens associated with the user ID when authenticating your
  ///             request.
  ///
  /// - [targetUserId]: The user ID of the user that you would like the `userId`
  ///                   to unmute.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:source_user_id/muting/:target_user_id
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - mute.write
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    50 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/mutes/api-reference/delete-users-user_id-muting
  Future<TwitterResponse<bool, void>> destroyMute(
      {required String userId, required String targetUserId});

  /// Returns a list of users who are muted by the specified user ID.
  ///
  /// The value returned when the [paging] callback is specified is
  /// the first object obtained that started the paging process. The value
  /// obtained in the paging process is passed to the [paging] callback
  /// function as a `PagingEvent` object.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID whose muted users you would like to retrieve.
  ///             The user’s ID must correspond to the user ID of the
  ///             authenticating user, meaning that you must pass the Access
  ///             Tokens associated with the user ID when authenticating your
  ///             request.
  ///
  /// - [maxResults]: The maximum number of results to be returned per page.
  ///                 This can be a number between 1 and 1000. By default, each
  ///                 page will return 100 results.
  ///
  /// - [paginationToken]: Used to request the next page of results if all
  ///                      results weren't returned with the latest request,
  ///                      or to go back to the previous page of results.
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users. The ID that
  ///                 represents the expanded data object will be included
  ///                 directly in the user data object, but the expanded object
  ///                 metadata will be returned within the includes response
  ///                 object, and will also include the ID so that you can match
  ///                this data object to the original Tweet object.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// - [paging]: If this callback function is specified, paging is
  ///             performed continuously until certain conditions are met.
  ///             This paging function is bi-directional,
  ///             both forward and backward, and allows for safe paging.
  ///             The response and other metadata obtained when paging is
  ///             performed is passed to the callback function as
  ///             `PagingEvent` object. So you can get the result of paging
  ///             from `PagingEvent` object. Also, the direction and continuity
  ///             of paging can be controlled by returning
  ///             `PaginationControl` object in the `paging` callback function.
  ///             Please use `PaginationControl.forward()` to continue paging
  ///             and move forward, or use `PaginationControl.backward()`
  ///             to move backward. And be sure to return
  ///             `PaginationControl.stop()` to terminate paging on
  ///             arbitrary conditions, otherwise paging continues until the
  ///             next page runs out.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id/muting
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - mute.read
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    15 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/mutes/api-reference/get-users-muting
  Future<TwitterResponse<List<UserData>, UserMeta>> lookupMutingUsers({
    required String userId,
    int? maxResults,
    String? paginationToken,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
    Paging<List<UserData>, UserMeta>? paging,
  });

  /// Causes the user (in the path) to block the target user.
  /// The user (in the path) must match the user Access Tokens being used to
  /// authorize the request.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID who you would like to initiate the block on behalf
  ///             of. It must match your own user ID or that of an
  ///             authenticating user, meaning that you must pass the Access
  ///             Tokens associated with the user ID when authenticating your
  ///             request.
  ///
  /// - [targetUserId]: The user ID of the user that you would like the id to
  ///                   block. The body should contain a string of the user ID
  ///                   inside of a JSON object.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id/blocking
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - block.write
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    50 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/blocks/api-reference/post-users-user_id-blocking
  Future<TwitterResponse<bool, void>> createBlock(
      {required String userId, required String targetUserId});

  /// Allows a user or authenticated user ID to unblock another user.
  ///
  /// The request succeeds with no action when the user sends a request to a
  /// user they're not blocking or have already unblocked.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID who you would like to initiate an unblock on
  ///             behalf of. The user’s ID must correspond to the user ID of the
  ///             authenticating user, meaning that you must pass the Access
  ///             Tokens associated with the user ID when authenticating your
  ///             request.
  ///
  /// - [targetUserId]: The user ID of the user that you would like to unblock.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id/blocking
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - block.write
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    50 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/blocks/api-reference/delete-users-user_id-blocking
  Future<TwitterResponse<bool, void>> destroyBlock(
      {required String userId, required String targetUserId});

  /// Returns a list of users who are blocked by the specified user ID.
  ///
  /// The value returned when the [paging] callback is specified is
  /// the first object obtained that started the paging process. The value
  /// obtained in the paging process is passed to the [paging] callback
  /// function as a `PagingEvent` object.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The user ID whose blocked users you would like to retrieve.
  ///             The user’s ID must correspond to the user ID of the
  ///             authenticating user, meaning that you must pass the Access
  ///             Tokens associated with the user ID when authenticating your
  ///             request.
  ///
  /// - [maxResults]: The maximum number of results to be returned per page.
  ///                 This can be a number between 1 and 1000. By default,
  ///                 each page will return 100 results.
  ///
  /// - [paginationToken]: Used to request the next page of results if all
  ///                      results weren't returned with the latest request,
  ///                      or to go back to the previous page of results.
  ///
  /// - [expansions]: Expansions enable you to request additional data objects
  ///                 that relate to the originally returned users. The ID that
  ///                 represents the expanded data object will be included
  ///                 directly in the user data object, but the expanded object
  ///                 metadata will be returned within the includes response
  ///                 object, and will also include the ID so that you can match
  ///                 this data object to the original Tweet object.
  ///
  /// - [tweetFields]: This fields parameter enables you to select which
  ///                  specific Tweet fields will deliver in each returned
  ///                  pinned Tweet. The Tweet fields will only return if the
  ///                  user has a pinned Tweet and if you've also included the
  ///                  `expansions=pinned_tweet_id` query parameter in your
  ///                  request. While the referenced Tweet ID will be located
  ///                  in the original Tweet object, you will find this ID and
  ///                  all additional Tweet fields in the includes data object.
  ///
  /// - [userFields]: This fields parameter enables you to select which specific
  ///                 user fields will deliver with each returned users objects.
  ///                 These specified user fields will display directly in the
  ///                 user data objects.
  ///
  /// - [paging]: If this callback function is specified, paging is
  ///             performed continuously until certain conditions are met.
  ///             This paging function is bi-directional,
  ///             both forward and backward, and allows for safe paging.
  ///             The response and other metadata obtained when paging is
  ///             performed is passed to the callback function as
  ///             `PagingEvent` object. So you can get the result of paging
  ///             from `PagingEvent` object. Also, the direction and continuity
  ///             of paging can be controlled by returning
  ///             `PaginationControl` object in the `paging` callback function.
  ///             Please use `PaginationControl.forward()` to continue paging
  ///             and move forward, or use `PaginationControl.backward()`
  ///             to move backward. And be sure to return
  ///             `PaginationControl.stop()` to terminate paging on
  ///             arbitrary conditions, otherwise paging continues until the
  ///             next page runs out.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/2/users/:id/blocking
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 2.0 Authorization Code with PKCE
  /// - OAuth 1.0a
  ///
  /// ## Required Scopes
  ///
  /// - tweet.read
  /// - users.read
  /// - block.read
  ///
  /// ## Rate Limits
  ///
  /// - **User rate limit (OAuth 2.0 user Access Token)**:
  ///    15 requests per 15-minute window per each authenticated user
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/users/blocks/api-reference/get-users-blocking
  Future<TwitterResponse<List<UserData>, UserMeta>> lookupBlockingUsers({
    required String userId,
    int? maxResults,
    String? paginationToken,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
    Paging<List<UserData>, UserMeta>? paging,
  });

  /// Updates the authenticating user's profile image. Note that this method
  /// expects raw multipart data, not a URL to an image.
  ///
  /// ## Parameters
  ///
  /// - [imageFile]: The avatar image for the profile, base64-encoded.
  ///                Must be a valid GIF, JPG, or PNG image of less than
  ///                700 kilobytes in size. Images with width larger than
  ///                400 pixels will be scaled down. Animated GIFs will be
  ///                converted to a static GIF of the first frame, removing
  ///                the animation.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/1.1/account/update_profile_image.json
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 1.0a
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_image
  Future<TwitterResponse<UserData, void>> updateProfileImage({
    required File imageFile,
  });

  /// Uploads a profile banner on behalf of the authenticating user.
  ///
  /// More information about sizing variations can be found in
  /// [User Profile Images and Banners](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/user-profile-images-and-banners).
  ///
  /// ## Parameters
  ///
  /// - [imageFile]: The file of user's new profile banner.
  ///
  /// - [width]: The width of the preferred section of the image being
  ///            uploaded in pixels. Use with [height], [offsetLeft],
  ///            and offset_top to select the desired region of the image to
  ///            use.
  ///
  /// - [height]: The height of the preferred section of the image being
  ///             uploaded in pixels. Use with [width], [offsetLeft], and
  ///             [offsetTop] to select the desired region of the image to use.
  ///
  /// - [offsetLeft]: The number of pixels by which to offset the uploaded
  ///                 image from the left. Use with [height], [width], and
  ///                 [offsetTop] to select the desired region of the image
  ///                 to use.
  ///
  /// - [offsetTop]: The number of pixels by which to offset the uploaded image
  ///                from the top. Use with [height], [width], and [offsetLeft]
  ///                to select the desired region of the image to use.
  ///
  /// ## Endpoint Url
  ///
  /// - https://api.twitter.com/1.1/account/update_profile_banner.json
  ///
  /// ## Authentication Methods
  ///
  /// - OAuth 1.0a
  ///
  /// ## Reference
  ///
  /// - https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/manage-account-settings/api-reference/post-account-update_profile_banner
  Future<TwitterResponse<bool, void>> updateProfileBanner({
    required File imageFile,
    int? width,
    int? height,
    int? offsetLeft,
    int? offsetTop,
  });
}

class _UsersService extends BaseService implements UsersService {
  /// Returns the new instance of [_UsersService].
  _UsersService({required super.context});

  @override
  Future<TwitterResponse<bool, void>> createFollow({
    required String userId,
    required String targetUserId,
  }) async =>
      super.evaluateResponse(
        await super.post(
          UserContext.oauth2OrOAuth1,
          '/2/users/$userId/following',
          body: {'target_user_id': targetUserId},
        ),
      );

  @override
  Future<TwitterResponse<bool, void>> destroyFollow({
    required String userId,
    required String targetUserId,
  }) async =>
      super.evaluateResponse(
        await super.delete(
          UserContext.oauth2OrOAuth1,
          '/2/users/$userId/following/$targetUserId',
        ),
      );

  @override
  Future<TwitterResponse<List<UserData>, UserMeta>> lookupFollowers({
    required String userId,
    int? maxResults,
    String? paginationToken,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
    Paging<List<UserData>, UserMeta>? paging,
  }) async =>
      await super.executePaginationIfNecessary(
        UserContext.oauth2OrOAuth1,
        '/2/users/$userId/followers',
        {
          'max_results': maxResults,
          'pagination_token': paginationToken,
          'expansions': expansions,
          'tweet.fields': tweetFields,
          'user.fields': userFields,
        },
        paging: paging,
        dataBuilder: UserData.fromJson,
        metaBuilder: UserMeta.fromJson,
      );

  @override
  Future<TwitterResponse<List<UserData>, UserMeta>> lookupFollowings({
    required String userId,
    int? maxResults,
    String? paginationToken,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
    Paging<List<UserData>, UserMeta>? paging,
  }) async =>
      await super.executePaginationIfNecessary(
        UserContext.oauth2OrOAuth1,
        '/2/users/$userId/following',
        {
          'max_results': maxResults,
          'pagination_token': paginationToken,
          'expansions': expansions,
          'tweet.fields': tweetFields,
          'user.fields': userFields,
        },
        paging: paging,
        dataBuilder: UserData.fromJson,
        metaBuilder: UserMeta.fromJson,
      );

  @override
  Future<TwitterResponse<UserData, void>> lookupById({
    required String userId,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  }) async =>
      super.transformSingleDataResponse(
        await super.get(
          UserContext.oauth2OrOAuth1,
          '/2/users/$userId',
          queryParameters: {
            'expansions': expansions,
            'tweet.fields': tweetFields,
            'user.fields': userFields,
          },
        ),
        dataBuilder: UserData.fromJson,
      );

  @override
  Future<TwitterResponse<List<UserData>, void>> lookupByIds({
    required List<String> userIds,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  }) async =>
      super.transformMultiDataResponse(
        await super.get(
          UserContext.oauth2OrOAuth1,
          '/2/users',
          queryParameters: {
            'ids': userIds,
            'expansions': expansions,
            'tweet.fields': tweetFields,
            'user.fields': userFields,
          },
        ),
        dataBuilder: UserData.fromJson,
      );

  @override
  Future<TwitterResponse<UserData, void>> lookupByName({
    required String username,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  }) async =>
      super.transformSingleDataResponse(
        await super.get(
          UserContext.oauth2OrOAuth1,
          '/2/users/by/username/$username',
          queryParameters: {
            'expansions': expansions,
            'tweet.fields': tweetFields,
            'user.fields': userFields,
          },
        ),
        dataBuilder: UserData.fromJson,
      );

  @override
  Future<TwitterResponse<List<UserData>, void>> lookupByNames({
    required List<String> usernames,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  }) async =>
      super.transformMultiDataResponse(
        await super.get(
          UserContext.oauth2OrOAuth1,
          '/2/users/by',
          queryParameters: {
            'usernames': usernames,
            'tweet.fields': tweetFields,
            'user.fields': userFields,
          },
        ),
        dataBuilder: UserData.fromJson,
      );

  @override
  Future<TwitterResponse<UserData, void>> lookupMe({
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
  }) async =>
      super.transformSingleDataResponse(
        await super.get(
          UserContext.oauth2OrOAuth1,
          '/2/users/me',
          queryParameters: {
            'expansions': expansions,
            'tweet.fields': tweetFields,
            'user.fields': userFields,
          },
        ),
        dataBuilder: UserData.fromJson,
      );

  @override
  Future<TwitterResponse<bool, void>> createMute({
    required String userId,
    required String targetUserId,
  }) async =>
      super.evaluateResponse(
        await super.post(
          UserContext.oauth2OrOAuth1,
          '/2/users/$userId/muting',
          body: {'target_user_id': targetUserId},
        ),
      );

  @override
  Future<TwitterResponse<bool, void>> destroyMute({
    required String userId,
    required String targetUserId,
  }) async =>
      super.evaluateResponse(
        await super.delete(
          UserContext.oauth2OrOAuth1,
          '/2/users/$userId/muting/$targetUserId',
        ),
      );

  @override
  Future<TwitterResponse<List<UserData>, UserMeta>> lookupMutingUsers({
    required String userId,
    int? maxResults,
    String? paginationToken,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
    Paging<List<UserData>, UserMeta>? paging,
  }) async =>
      await super.executePaginationIfNecessary(
        UserContext.oauth2OrOAuth1,
        '/2/users/$userId/muting',
        {
          'max_results': maxResults,
          'pagination_token': paginationToken,
          'expansions': expansions,
          'tweet.fields': tweetFields,
          'user.fields': userFields,
        },
        paging: paging,
        dataBuilder: UserData.fromJson,
        metaBuilder: UserMeta.fromJson,
      );

  @override
  Future<TwitterResponse<bool, void>> createBlock({
    required String userId,
    required String targetUserId,
  }) async =>
      super.evaluateResponse(
        await super.post(
          UserContext.oauth2OrOAuth1,
          '/2/users/$userId/blocking',
          body: {'target_user_id': targetUserId},
        ),
      );

  @override
  Future<TwitterResponse<bool, void>> destroyBlock({
    required String userId,
    required String targetUserId,
  }) async =>
      super.evaluateResponse(
        await super.delete(
          UserContext.oauth2OrOAuth1,
          '/2/users/$userId/blocking/$targetUserId',
        ),
      );

  @override
  Future<TwitterResponse<List<UserData>, UserMeta>> lookupBlockingUsers({
    required String userId,
    int? maxResults,
    String? paginationToken,
    List<UserExpansion>? expansions,
    List<TweetField>? tweetFields,
    List<UserField>? userFields,
    Paging<List<UserData>, UserMeta>? paging,
  }) async =>
      await super.executePaginationIfNecessary(
        UserContext.oauth2OrOAuth1,
        '/2/users/$userId/blocking',
        {
          'max_results': maxResults,
          'pagination_token': paginationToken,
          'expansions': expansions,
          'tweet.fields': tweetFields,
          'user.fields': userFields,
        },
        paging: paging,
        dataBuilder: UserData.fromJson,
        metaBuilder: UserMeta.fromJson,
      );

  @override
  Future<TwitterResponse<UserData, void>> updateProfileImage({
    required File imageFile,
  }) async =>
      super.transformSingleDataResponse(
        await super.postMultipart(
          UserContext.oauth1Only,
          '/1.1/account/update_profile_image.json',
          files: [
            MultipartFile.fromBytes('image', imageFile.readAsBytesSync()),
          ],
          queryParameters: {
            'include_entities': false,
            'skip_status': true,
          },
        ),
        dataBuilder: UserData.fromJson,
        adaptor: const UserObjectAdaptor(),
      );

  @override
  Future<TwitterResponse<bool, void>> updateProfileBanner({
    required File imageFile,
    int? width,
    int? height,
    int? offsetLeft,
    int? offsetTop,
  }) async =>
      super.evaluateResponse(
        await super.postMultipart(
          UserContext.oauth1Only,
          '/1.1/account/update_profile_banner.json',
          files: [
            MultipartFile.fromBytes('banner', imageFile.readAsBytesSync()),
          ],
          queryParameters: {
            'width': width,
            'height': height,
            'offset_left': offsetLeft,
            'offset_top': offsetTop,
          },
        ),
      );
}
