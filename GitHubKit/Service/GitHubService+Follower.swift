import Foundation

import Moya
import RxSwift

public extension GitHubService {

  // swiftlint:disable:next line_length
  /// [Check if one user follows another](https://developer.github.com/v3/users/followers/#check-if-one-user-follows-another)
  ///
  /// - Parameters:
  ///   - username: User name.
  ///   - targetUsername: Target user name.
  /// - Returns: Single<Bool>
  func isFollowing(from username: String, to targetUsername: String) -> Single<IsFollowingResponse> {
    return provider.request(.isFollowing(username: username, targetUsername: targetUsername))
      .map(IsFollowingResponse.init)
  }

  typealias FollowersResponse = Response<[Follower]>

  // swiftlint:disable:next line_length
  /// [List users followed by another user](https://developer.github.com/v3/users/followers/#list-users-followed-by-another-user)
  ///
  /// - Parameters:
  ///   - username: User name.
  /// - Returns: `FollowersResponse`, alias of `Response<[Follower]>`.
  func followers(of username: String) -> Single<FollowersResponse> {
    return provider.request(.followers(username: username))
      .map(FollowersResponse.init)
  }

  /// [Follow a user](https://developer.github.com/v3/users/followers/#follow-a-user)
  ///
  /// - Parameter username: Username.
  /// - Returns: Completable.
  func follow(username: String) -> Completable {
    return provider.request(.follow(username: username))
      .asCompletable()
  }

  /// [Unfollow a user](https://developer.github.com/v3/users/followers/#follow-a-user)
  ///
  /// - Important: This endpoint requires basic authorization or OAuth
  ///   with 'user:follow' scope which is included in scope 'user'.
  ///
  /// - Parameter username: Username.
  /// - Returns: Completable.
  func unfollow(username: String) -> Completable {
    return provider.request(.unfollow(username: username))
      .asCompletable()
  }

}
