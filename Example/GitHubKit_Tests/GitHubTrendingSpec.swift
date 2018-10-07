import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class GitHubTrendingSpec: QuickSpec { override func spec() {

  beforeEach {
    NetworkStubbing.setup()
  }

  afterEach {
    OHHTTPStubs.removeAllStubs()
  }

  describe("GitHubTrending") {

    it("repositories") {
      // Arrange
      let jack = Jack("Test.GitHubTrending.repositories(of:in:)")

      NetworkStubbing.stubIfEnabled(
        name: "repository-trending",
        condition: isMethodGET() && pathStartsWith("/trending")
      )

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubTrending.repositories(of: "swift", in: .pastMonth)
          .subscribe(
            onSuccess: { _ in
              done()
            },
            onError: { error in
              jack.error(Jack.dump(of: error))
              fatalError()
            }
          )
      }
    }

    it("developers") {
      // Arrange
      let jack = Jack("Test.GitHubTrending.developers(of:in)")

      NetworkStubbing.stubIfEnabled(
        name: "developer-trending",
        condition: isMethodGET() && pathStartsWith("/trending/developers")
      )

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubTrending.developers(of: "swift", in: .pastWeek)
          .subscribe(
            onSuccess: { _ in
              done()
            },
            onError: { error in
              jack.error(Jack.dump(of: error))
              fatalError()
            }
          )
      }
    }
  }

} }
