import Foundation

import JacKit
import OHHTTPStubs

import Nimble
import Quick

import GitHub

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

  static var gitHubService: GitHub.Service = {
    let plugin = AuthPlugin(token: Vault.token, user: Vault.user, app: Vault.app)
    return GitHub.Service(authPlugin: plugin)
  }()
  
}
