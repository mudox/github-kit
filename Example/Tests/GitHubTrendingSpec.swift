import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class GitHubTrendingSpec: QuickSpec { override func spec() {

  beforeEach {
    Jack.formattingOptions = [.noLocation]
    NetworkStubbing.setup()
  }

  afterEach {
    OHHTTPStubs.removeAllStubs()
  }

  // MARK: downloadGitHubExplore

  describe("GitHubTrending") {

    fit("lists trending repositories") {
      // Arrange
      let jack = Jack("Trending.repositories")

      NetworkStubbing.stubIfEnabled(
        name: "repository-trending",
        condition: isMethodGET() && pathStartsWith("/trending")
      )

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubTrending.trendings(of: .repository, language: "swift", period: .monthly)
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

    it("lists trending developers") {
      // Arrange
      let jack = Jack("Trending.developers")

      NetworkStubbing.stubIfEnabled(
        name: "developer-trending",
        condition: isMethodGET() && pathStartsWith("/trending/developers")
      )

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubTrending.trendings(of: .deveoloper, language: "swift", period: .weekly)
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
