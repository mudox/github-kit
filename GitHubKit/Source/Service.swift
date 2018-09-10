import Foundation

import Moya

import RxSwift

import JacKit

extension GitHub {

  struct Service {
    // MARK: - Singleton

    static let shared = Service()
    private init() {}

    // MARK: - MoyaProvider

    private let provider = MoyaProvider<GitHub.MoyaTarget>().rx

    // MARK: - Search


    typealias SearchRepositoryResponse = GitHub.PagedResponse<GitHub.ResponsePayload.Search>


    /// Search GitHub repositories.
    ///
    /// - Parameter query: Query string. See [Understanding the search syntax](https://help.github.com/articles/understanding-the-search-syntax/)
    ///   and [Searching for repositories](https://help.github.com/articles/searching-for-repositories/)
    /// - Returns: Single\<SearchRepositoryResponse\>.
    func searchRepository(_ query: String) -> Single<SearchRepositoryResponse> {
      return provider.request(.searchRepository(query))
        .map(SearchRepositoryResponse.init)
    }

    // MARK: - User

    typealias CurrentUserResponse = GitHub.Response<GitHub.SignedInUser>


    /// Get full information of current (signed-in) GitHub user.
    ///
    /// - Returns: Single\<CurrentUserResponse\>.
    func currentUser() -> Single<CurrentUserResponse> {
      return provider.request(.currentUser)
        .map(CurrentUserResponse.init)
    }

    typealias UserResponse = GitHub.Response<GitHub.User>

    /// Get public information of a GitHub user with given username.
    ///
    /// - Returns: Single\<UserResponse\>.
    func user(name: String) -> Single<UserResponse> {
      return provider.request(.user(name: name))
        .map(UserResponse.init)
    }

    // MARK: - Misc

    /// Request a random GitHub philosophy.
    ///
    /// - Returns: RxSwift.Single\<String\>.
    func zen() -> Single<String> {
      return provider.request(.zen).mapString()
    }

    /// Request rate limit status for current user.
    ///
    /// - Returns: Single\<GitHub.ResponsePayload.RateLimit\>.
    func rateLimit() -> Single<GitHub.ResponsePayload.RateLimit> {
      return provider.request(.rateLimit)
        .map(GitHub.ResponsePayload.RateLimit.self)
    }

    // MARK: - Authorization

    typealias AuthorizeResponse = GitHub.Response<GitHub.Authorization>

    /// Create a new authorization.
    ///
    /// - Returns: RxSwift.Single\<AuthoriztionResponse\>
    func authorize() -> Single<AuthorizeResponse> {
      return provider.request(.authorize)
        .map(AuthorizeResponse.init)
    }

    /// Revoke an authorization with given ID.
    ///
    /// - Parameter id: Authorization ID.
    /// - Returns: RxSwift.Completable.
    func deleteAuthorization(id: Int) -> Completable {
      return provider.request(.deleteAuthorization(id: id))
        .map { response -> Moya.Response in
          if response.statusCode != 204 {
            Jack("GitHub.Service.deleteAuthorization").warn("""
            expect status code 204, got \(response.statusCode)
            \(Jack.dump(of: response))
            """)
          }
          return response
        }
        .asCompletable()
    }

    typealias AuthorizationsResponse = GitHub.Response<[GitHub.Authorization]>

    /// Request all authorization granted from current user.
    ///
    /// - Returns: Single\<AuthorizationsResponse\>.
    func authorizations() -> Single<AuthorizationsResponse> {
      return provider.request(.authorizations)
        .map(AuthorizationsResponse.init)
    }

    // MARK: - Grant

    /// Request all grants associated with current user.
    ///
    /// - Returns: Single\<GrantsResponse\>.
    typealias GrantsResponse = GitHub.Response<[GitHub.Grant]>

    func grants() -> Single<GrantsResponse> {
      return provider.request(.grants)
        .map(GrantsResponse.init)
    }

    /// Revoke a grant with given ID.
    ///
    /// - Parameter id: Grant ID.
    /// - Returns: RxSwift.Completable.
    func deleteGrant(id: Int) -> Completable {
      return provider.request(.deleteGrant(id: id))
        .map { response -> Moya.Response in
          if response.statusCode != 204 {
            Jack("GitHub.Service.deleteGrant").warn("""
            expect status code 204, got \(response.statusCode)
            \(Jack.dump(of: response))
            """)
          }
          return response
        }
        .asCompletable()
    }


  } // struct Service
} // extension GitHub
