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

  fdescribe("GitHubExplore") {

    it("synchronize") {
      // Arrange
      let jack = Jack("curatedTopics")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubTrending.test(of: .repository)
          .subscribe(
            onSuccess: { string in
              jack.info("Page HTML string legnth: \(string.count)")
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
