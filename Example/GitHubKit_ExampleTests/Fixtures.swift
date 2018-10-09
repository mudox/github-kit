import Foundation

import JacKit
import OHHTTPStubs

import Nimble
import Quick

import GitHubKit

enum Fixtures {
  
  static let setup: BeforeExampleClosure = { () -> Void in
    // Logging
    Jack("Test")
      .set(options: .noLocation)
    //      .set(level: .verbose)

    // Stubbing
    NetworkStubbing.setup()

    // Nimble
    AsyncDefaults.Timeout = 1000
    AsyncDefaults.PollInterval = 0.1
  }

  static let cleanup: AfterExampleClosure = { () -> Void in
    OHHTTPStubs.removeAllStubs()
  }

  static var gitHubService: GitHubService = {
    let plugin = AuthPlugin(token: Auth.token, user: Auth.user, app: Auth.app)
    return GitHubService(authPlugin: plugin)
  }()
  
}
