import Foundation

import JacKit
import OHHTTPStubs

import Nimble
import Quick

import GitHubKit

class BaseSpec: QuickSpec {

  let setup: BeforeExampleClosure = { () -> Void in
    // Logging
    Jack("Test").set(options: .noLocation)

    // Stubbing
    NetworkStubbing.setup()

    // Nimble
    AsyncDefaults.Timeout = 1000
    AsyncDefaults.PollInterval = 0.1
  }

  let clean: AfterExampleClosure = { () -> Void in
    OHHTTPStubs.removeAllStubs()
  }

}

class GitHubServiceBaseSpec: BaseSpec {

  /// The GitHubService instance to be tested
  var service: GitHubService {
    let plugin = AuthPlugin(token: Auth.token, user: Auth.user, app: Auth.app)
    return GitHubService(authPlugin: plugin)
  }

}
