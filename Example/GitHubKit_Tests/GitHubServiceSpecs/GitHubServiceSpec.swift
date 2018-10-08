import Foundation

import Quick

import JacKit

import GitHubKit

let timeout: TimeInterval = 10

/// Superclass of other spec classes
class GitHubServiceSpec: QuickSpec {

  /// The GitHubService instance to be tested
  var service: GitHubService {
    let plugin = AuthPlugin(token: Auth.token, user: Auth.user, app: Auth.app)
    return GitHubService(authPlugin: plugin)
  }

  let beforeEachClosure: BeforeExampleClosure = { () -> Void in
    // Logging
    Jack("Test").set(options: .noLocation)

    // Stubbing
    NetworkStubbing.setup()
  }

}
