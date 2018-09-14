import Foundation

import Alamofire
import Moya

import RxSwift

import JacKit

public struct Service {
  // MARK: - Singleton

  public static let shared = Service()

  private init() {}

  // MARK: - MoyaProvider

  private let provider = MoyaProvider<MoyaTarget>().rx

  // MARK: - Search

  public typealias SearchRepositoryResponse = PagedResponse<SearchPayload>

  /// Search GitHub repositories.
  ///
  /// See Also:
  /// - [Understanding the search syntax](https://help.com/articles/understanding-the-search-syntax/)
  /// - [Searching for repositories](https://help.com/articles/searching-for-repositories/)
  ///
  /// - Parameter query: Query string.
  ///
  /// - Returns: Single\<SearchRepositoryResponse\>.
  public func searchRepository(_ query: String) -> Single<SearchRepositoryResponse> {
    return provider.request(.searchRepository(query))
      .map(SearchRepositoryResponse.init)
  }

  // MARK: - User

  public typealias CurrentUserResponse = Response<SignedInUser>

  /// Get public as well as private information of current (signed-in) GitHub user.
  ///
  /// - Returns: Single\<CurrentUserResponse\>.
  public func currentUser() -> Single<CurrentUserResponse> {
    return provider.request(.currentUser)
      .map(CurrentUserResponse.init)
  }

  public typealias UserResponse = Response<User>

  /// Get public information of a GitHub user with given username.
  ///
  /// - Returns: Single\<UserResponse\>.
  public func user(name: String) -> Single<UserResponse> {
    return provider.request(.user(name: name))
      .map(UserResponse.init)
  }

  // MARK: Follower

  // swiftlint:disable:next line_length
  /// [Check if one user follows another](https://developer.github.com/v3/users/followers/#check-if-one-user-follows-another)
  ///
  /// - Parameters:
  ///   - username: User name.
  ///   - targetUsername: Target user name.
  /// - Returns: Single<Bool>
  public func isFollowing(from username: String, to targetUsername: String) -> Single<IsFollowingResponse> {
    return provider.request(.isFollowing(username: username, targetUsername: targetUsername))
      .map(IsFollowingResponse.init)
  }
  // MARK: - Misc

  /// Request a random GitHub philosophy.
  ///
  /// - Returns: RxSwift.Single\<String\>.
  public func zen() -> Single<String> {
    return provider.request(.zen).mapString()
  }

  /// Request rate limit status for current user.
  ///
  /// - Returns: Single\<RateLimitPayload\>.
  public func rateLimit() -> Single<RateLimitPayload> {
    return provider.request(.rateLimit)
      .map(RateLimitPayload.self)
  }

  // MARK: - Authorization

  public typealias AuthorizeResponse = Response<Authorization>

  /// Create a new authorization.
  ///
  /// - Returns: RxSwift.Single\<AuthoriztionResponse\>
  public func authorize() -> Single<AuthorizeResponse> {
    return provider.request(.authorize)
      .map(AuthorizeResponse.init)
  }

  /// Revoke an authorization with given ID.
  ///
  /// - Parameter id: Authorization ID.
  /// - Returns: RxSwift.Completable.
  public func deleteAuthorization(id: Int) -> Completable {
    return provider.request(.deleteAuthorization(id: id))
      .map { response -> Moya.Response in
        if response.statusCode != 204 {
          Jack("Service.deleteAuthorization").warn("""
          expect status code 204, got \(response.statusCode)
          \(Jack.dump(of: response))
          """)
        }
        return response
      }
      .asCompletable()
  }

  public typealias AuthorizationsResponse = Response<[Authorization]>

  /// Request all authorization granted from current user.
  ///
  /// - Returns: Single\<AuthorizationsResponse\>.
  public func authorizations() -> Single<AuthorizationsResponse> {
    return provider.request(.authorizations)
      .map(AuthorizationsResponse.init)
  }

  // MARK: - Grant

  /// Request all grants associated with current user.
  ///
  /// - Returns: Single\<GrantsResponse\>.
  public typealias GrantsResponse = Response<[Grant]>

  public func grants() -> Single<GrantsResponse> {
    return provider.request(.grants)
      .map(GrantsResponse.init)
  }

  /// Revoke a grant with given ID.
  ///
  /// - Parameter id: Grant ID.
  /// - Returns: RxSwift.Completable.
  public func deleteGrant(id: Int) -> Completable {
    return provider.request(.deleteGrant(id: id))
      .map { response -> Moya.Response in
        if response.statusCode != 204 {
          Jack("Service.deleteGrant").warn("""
          expect status code 204, got \(response.statusCode)
          \(Jack.dump(of: response))
          """)
        }
        return response
      }
      .asCompletable()
  }

  // MARK: - Data

  public typealias ReferenceResponse = Response<Reference>

  public func reference(
    of ownerName: String, _ repositoryName: String,
    withPath path: String
  )
    -> Single<ReferenceResponse> {
    return provider.request(.reference(ownerName: ownerName, repositoryName: repositoryName, path: path))
      .map(ReferenceResponse.init)
  }

  public typealias CommitResponse = Response<Commit>

  public func commit(
    of ownerName: String, _ repositoryName: String,
    withSHA sha: String
  )
    -> Single<CommitResponse> {

    return provider.request(.commit(ownerName: ownerName, repositoryName: repositoryName, sha: sha))
      .map(CommitResponse.init)
  }

  public typealias TreeResponse = Response<Tree>

  public func tree(
    of ownerName: String, _ repositoryName: String,
    withSHA sha: String
  )
    -> Single<TreeResponse> {
    return provider.request(.tree(ownerName: ownerName, repositoryName: repositoryName, sha: sha))
      .map(TreeResponse.init)
  }

  public typealias BlobRawResponse = RawDataResponse

  /// [Get a blob](https://developer.github.com/v3/git/blobs/#get-a-blob)
  ///
  /// - Parameters:
  ///   - ownerName: Owner username of the repository from which to get the blob.
  ///   - repositoryName: The repository name.
  ///   - sha: SHA-1 value of the blob object.
  /// - Returns: `Single<BlobRawResponse>`
  public func blob(
    of ownerName: String, _ repositoryName: String,
    withSHA sha: String
  )
    -> Single<BlobRawResponse> {
    return provider.request(.blob(ownerName: ownerName, repositoryName: repositoryName, sha: sha))
      .map(BlobRawResponse.init)
  }

} // struct Service
