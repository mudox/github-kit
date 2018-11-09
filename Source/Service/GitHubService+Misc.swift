import Foundation

import RxSwift

public extension Service {

  /// Request a random GitHub philosophy.
  ///
  /// - Returns: RxSwift.Single\<String\>.
  func zen() -> Single<String> {
    return provider.rx.request(.zen).mapString()
  }

  /// Request rate limit status for current user.
  ///
  /// - Returns: Single\<RateLimitPayload\>.
  func rateLimit() -> Single<RateLimitPayload> {
    return provider.rx.request(.rateLimit)
      .map(RateLimitPayload.self)
  }

}
