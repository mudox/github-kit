import Foundation

import RxSwift

public extension Service {
  
  /// Request a random GitHub philosophy.
  ///
  /// - Returns: RxSwift.Single\<String\>.
  func zen() -> Single<String> {
    return provider.request(.zen).mapString()
  }

  /// Request rate limit status for current user.
  ///
  /// - Returns: Single\<RateLimitPayload\>.
  func rateLimit() -> Single<RateLimitPayload> {
    return provider.request(.rateLimit)
      .map(RateLimitPayload.self)
  }

}
