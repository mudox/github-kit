import Foundation

import Moya
import RxSwift

import JacKit

private let jack = Jack("GitHub.Service.Authorization")

public extension Service {
  // MARK: - Authorization

  typealias AuthorizeResponse = Response<Authorization>

  /// Create a new authorization.
  ///
  /// - Important: Before using this method, set __service.credentialService.user__
  ///   and __service.credentialService.app__ to valid credentials.
  ///
  /// - Returns: RxSwift.Single\<AuthoriztionResponse\>
  func authorize(authScope: AuthScope, note: String? = nil) -> Single<AuthorizeResponse> {

    guard credentialService.user != nil else {
      return .error(Error.invalidParameter("need an non-nil `self.credentialService.user`"))
    }

    guard let app = credentialService.app else {
      return .error(Error.invalidParameter("need an non-nil `self.credentialService.app`"))
    }

    let target = APIv3.authorize(
      appKey: app.key,
      appSecret: app.secret,
      authScope: authScope,
      note: note
    )

    return provider.rx.request(target)
      .map(AuthorizeResponse.init)
      .do(onSuccess: { [weak self] reponse in
        // Store the access token
        guard let `self` = self else {
          jack.descendant("authorize.do.onSuccess").warn("weakly captured self is nil")
          return
        }
        self.credentialService.token = reponse.payload.token
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
