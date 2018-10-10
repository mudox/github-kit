import Foundation

import Moya
import RxSwift

import  JacKit

private let jack = Jack("GitHub.Service.Authorization")

public struct AuthParameter {
  // Required
  public let user: (name: String, password: String)
  public let app: (key: String, secret: String)

  public let scope: AuthScope

  // Optional
  public let note: String?

  public init(
    user: (name: String, password: String),
    app: (key: String, secret: String),
    scope: AuthScope,
    note: String? = nil
  ) {
    self.app = app
    self.user = user
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
  func authorize(with paramters: AuthParameter) -> Single<AuthorizeResponse> {
    return provider.rx.request(.authorize(paramters))
      .map(AuthorizeResponse.init)
      .do(onSuccess: { [weak self] reponse in
        guard let `self` = self else {
          jack.descendant("authorize.do.onSuccess").warn("weakly captured self is nil")
          return
        }

        self.credentialService.token = reponse.payload.token
        self.credentialService.user = paramters.user
        self.credentialService.app = paramters.app
      })
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
