import Foundation

import Moya
import RxSwift

public struct AuthorizationParameter {
  // Required
  public let appKey: String
  public let appSecret: String
  public let scope: AuthorizationScope

  // Optional
  public let note: String?

  public init(appKey: String, appSecret: String, scope: AuthorizationScope, note: String? = nil) {
    self.appKey = appKey
    self.appSecret = appSecret
    self.scope = scope
      self.note = note
  }
}

public extension Service {
  // MARK: - Authorization

  typealias AuthorizeResponse = Response<Authorization>

  /// Create a new authorization.
  ///
  /// - Returns: RxSwift.Single\<AuthoriztionResponse\>
  func authorize(with paramters: AuthorizationParameter) -> Single<AuthorizeResponse> {
    return provider.rx.request(.authorize(paramters))
      .map(AuthorizeResponse.init)
  }

  /// Revoke an authorization with given ID.
  ///
  /// - Parameter id: Authorization ID.
  /// - Returns: RxSwift.Completable.
  func deleteAuthorization(id: Int) -> Completable {
    return provider.rx.request(.deleteAuthorization(id: id))
      .asCompletable()
  }

  typealias AuthorizationsResponse = Response<[Authorization]>

  /// Request all authorization granted from current user.
  ///
  /// - Returns: Single\<AuthorizationsResponse\>.
  func authorizations() -> Single<AuthorizationsResponse> {
    return provider.rx.request(.authorizations)
      .map(AuthorizationsResponse.init)
  }

  // MARK: - Grant

  /// Request all grants associated with current user.
  ///
  /// - Returns: Single\<GrantsResponse\>.
  typealias GrantsResponse = Response<[Grant]>

  func grants() -> Single<GrantsResponse> {
    return provider.rx.request(.grants)
      .map(GrantsResponse.init)
  }

  /// Revoke a grant with given ID.
  ///
  /// - Parameter id: Grant ID.
  /// - Returns: RxSwift.Completable.
  func deleteGrant(id: Int) -> Completable {
    return provider.rx.request(.deleteGrant(id: id))
      .asCompletable()
  }
}
