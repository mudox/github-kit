import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

private let jack = Jack().set(format: .short)

class GitHubTrendingSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  describe("GitHub.Trending") {

    // MARK: repositories

    it("repositories") {
      // Arrange
      let log = jack.sub("repositories")

      HTTPStubbing.stubIfEnabled(
        name: "repository-trending",
        condition: isMethodGET() && pathStartsWith("/trending")
      )

      // Act, Assert
      waitUntil { done in
        _ = Trending().repositories(of: "swift", for: .thisMonth)
          .subscribe(
            onSuccess: { _ in
              done()
            },
            onError: { error in
              log.error(dump(of: error))
              fatalError()
            }
          )
      }
    }

    // MARK: developers

    it("developers") {
      // Arrange
      let log = jack.sub("developers")

      HTTPStubbing.stubIfEnabled(
        name: "developer-trending",
        condition: isMethodGET() && pathStartsWith("/trending/developers")
      )

      // Act, Assert
      waitUntil { done in
        _ = Trending().developers(of: "swift", for: .thisWeek)
          .subscribe(
            onSuccess: { _ in
              done()
            },
            onError: { error in
              log.error(dump(of: error))
              fatalError()
            }
          )
      }
    }
  }

} }
