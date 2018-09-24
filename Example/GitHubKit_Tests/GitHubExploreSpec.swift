import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class GitHubExploreSpec: QuickSpec { override func spec() {

  beforeEach {
    NetworkStubbing.setup()
  }

  afterEach {
    OHHTTPStubs.removeAllStubs()
  }

  describe("GitHubExplore") {

    // MARK: curatedTopics

    it("curatedTopics") {
      // Arrange
      let jack = Jack("Test.GitHubExplore.curatedTopics")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubExplore.curatedTopics(aftreSync: true)
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
      }
    }

    // MARK: collections

    it("collections") {
      // Arrange
      let jack = Jack("Test.GitHubExplore.collections")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubExplore.collections(afterSync: true)
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
      }
    }

  } // describe("GitHubExplore")

} }
