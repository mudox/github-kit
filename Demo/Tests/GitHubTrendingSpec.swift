import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class GitHubTrendingSpec: QuickSpec { override func spec() {
  
  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  describe("GitHub.Trending") {

    it("repositories") {
      // Arrange
      let jack = Jack("Test.GitHub.Trending.repositories(of:in:)")

      NetworkStubbing.stubIfEnabled(
        name: "repository-trending",
        condition: isMethodGET() && pathStartsWith("/trending")
      )

      // Act, Assert
      waitUntil { done in
        _ = Trending.repositories(of: "swift", in: .pastMonth)
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
      let jack = Jack("Test.GitHub.Trending.developers(of:in)")

      NetworkStubbing.stubIfEnabled(
        name: "developer-trending",
        condition: isMethodGET() && pathStartsWith("/trending/developers")
      )

      // Act, Assert
      waitUntil { done in
        _ = Trending.developers(of: "swift", in: .pastWeek)
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
