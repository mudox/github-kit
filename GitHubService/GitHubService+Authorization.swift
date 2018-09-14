import Foundation

import Moya
import RxSwift

public extension Service {

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
      .asCompletable()
  }

}
