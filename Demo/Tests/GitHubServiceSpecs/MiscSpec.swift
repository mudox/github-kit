import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class MiscSpec: QuickSpec { override func spec() {

beforeEach(Fixtures.setup)
afterEach(Fixtures.cleanup)

  // MARK: zen

  it("zen") {
    // Arrange
    let jack = Jack("Test.Service.user")

    HTTPStubbing.stubIfEnabled(
      name: "zen",
      condition: isMethodGET() && isPath("/zen")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.zen().subscribe(
        onSuccess: { zen in
          jack.info("GitHub Zen: \(zen)")
          done()
        },
        onError: { jack.error(dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: rateLimit

  it("rateLimit") {
    // Arrange
    let jack = Jack("Test.Service.rateLimit")

    HTTPStubbing.stubIfEnabled(
      name: "rateLimit",
      condition: isMethodGET() && isPath("/rate_limit")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.rateLimit().subscribe(
        onSuccess: { rateLimit in
          jack.info(dump(of: rateLimit))
          done()
        },
        onError: { jack.error(dump(of: $0)); fatalError() }
      )
    }
  }

} }
