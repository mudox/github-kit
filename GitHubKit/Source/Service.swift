import Foundation

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
  /// - Parameter query: Query string. See
  /// [Understanding the search syntax](https://help.com/articles/understanding-the-search-syntax/) and
  /// [Searching for repositories](https://help.com/articles/searching-for-repositories/)
  /// - Returns: Single\<SearchRepositoryResponse\>.
  public func searchRepository(_ query: String) -> Single<SearchRepositoryResponse> {
    return provider.request(.searchRepository(query))
      .map(SearchRepositoryResponse.init)
  }

  // MARK: - User

  public typealias CurrentUserResponse = Response<SignedInUser>

  /// Get full information of current (signed-in) GitHub user.
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

  public func reference(ownerName: String, repositoryName: String, path: String) -> Single<ReferenceResponse> {
    return provider.request(.reference(ownerName: ownerName, repositoryName: repositoryName, path: path))
      .map(ReferenceResponse.init)
  }

  public typealias CommitResponse = Response<Commit>

  public func commit(ownerName: String, repositoryName: String, sha: String) -> Single<CommitResponse> {
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
} // struct Service
