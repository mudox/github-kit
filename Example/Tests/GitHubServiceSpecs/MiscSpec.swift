import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class MiscSpec: QuickSpec { override func spec() {

  beforeEach {
    Jack.formattingOptions = [.noLocation]
    NetworkStubbing.setup()
  }

  afterEach {
    OHHTTPStubs.removeAllStubs()
  }

  // MARK: zen

  it("zen") {
    // Arrange
    let jack = Jack("Service.user")

    NetworkStubbing.stubIfEnabled(
      name: "zen",
      condition: isMethodGET() && isPath("/zen")
    )

    // Act, Assert
    waitUntil(timeout: timeout) { done in
      _ = Service.shared.zen().subscribe(
        onSuccess: { zen in
          jack.info("GitHub Zen: \(zen)")
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: rateLimit

  it("rateLimit") {
    // Arrange
    let jack = Jack("Service.rateLimit")

    NetworkStubbing.stubIfEnabled(
      name: "rateLimit",
      condition: isMethodGET() && isPath("/rate_limit")
    )

    // Act, Assert
    waitUntil(timeout: timeout) { done in
      _ = Service.shared.rateLimit().subscribe(
        onSuccess: { rateLimit in
          jack.info(Jack.dump(of: rateLimit))
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

} }
