import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class GitHubExploreSpec: QuickSpec { override func spec() {

  beforeEach {
    Jack.formattingOptions = [.noLocation]
    NetworkStubbing.setup()
  }

  afterEach {
    OHHTTPStubs.removeAllStubs()
  }

  // MARK: downloadGitHubExplore

  fdescribe("GitHubExplore") {

    it("curatedTopics") {
      // Arrange
      let jack = Jack("curatedTopics")

      // Act, Assert
      waitUntil(action: { done in
        _ = GitHubExplore.curatedTopics
          .subscribe(
            onSuccess: { topics in
              jack.info("Found \(topics.count) curated topics")
              done()
            },
            onError: { error in
              jack.error(Jack.dump(of: error))
              fatalError()
            }
          )
      })
    }

    it("collections") {
      // Arrange
      let jack = Jack("collections")

      // Act, Assert
      waitUntil(action: { done in
        _ = GitHubExplore.collections
          .subscribe(
            onSuccess: { collections in
              jack.info("Found \(collections.count) collections")
              done()
            },
            onError: { error in
              jack.error(Jack.dump(of: error))
              fatalError()
            }
          )
      })
    }
  } // describe("GitHubExplore")

} }
