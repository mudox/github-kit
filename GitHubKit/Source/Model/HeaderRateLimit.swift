import Foundation
import Moya

import RxSwift

public struct HeaderRateLimit {
  
  // MARK: - Stored Properties

  public let remainingCount: Int
  public let totalCount: Int
  public let resetTimeIntervalSince1970: TimeInterval

  // MARK: - Initializer

  public init?(from headers: [String: String]) {
    guard
      let limit = headers["X-RateLimit-Limit"],
      let totalCount = Int(limit),
      let remaining = headers["X-RateLimit-Remaining"],
      let remainingCount = Int(remaining),
      let reset = headers["X-RateLimit-Reset"],
      let resetTimeInterval = TimeInterval(reset)
    else {
      return nil
    }

    self.totalCount = totalCount
    self.remainingCount = remainingCount
    resetTimeIntervalSince1970 = resetTimeInterval
  }

  // MARK: - Computed Properties

  public var isExceeded: Bool {
    return remainingCount > 0
  }

  public var resetInterval: TimeInterval {
    return resetTimeIntervalSince1970 - Date().timeIntervalSince1970
  }

}

// MARK: - CustomReflectable

extension HeaderRateLimit: CustomReflectable {

  public var customMirror: Mirror {
    return Mirror(
      RateLimit.self,
      children: [
        "remain": remainingCount,
        "total": totalCount,
        "reset": "in \(Int(resetInterval))s",
      ]
    )
  }

}
