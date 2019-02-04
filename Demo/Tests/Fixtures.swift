import Foundation

import JacKit
import OHHTTPStubs

import Nimble
import Quick

import GitHub

enum Fixtures {
  
  static let setup: BeforeExampleClosure = { () -> Void in
    
    // Logging
    Jack("Test").set(format: .noLocation)

    // Stubbing
    HTTPStubbing.setup()

    // Nimble
    AsyncDefaults.Timeout = 1000
    AsyncDefaults.PollInterval = 0.1
  }

  static let cleanup: AfterExampleClosure = { () -> Void in
    OHHTTPStubs.removeAllStubs()
  }

  static var gitHubService: GitHub.Service = {
    return GitHub.Service(credentials: Credentials.valid)
  }()
  
}
