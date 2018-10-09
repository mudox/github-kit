import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class GitHubExploreSpec: QuickSpec { override func spec() {
  
  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  describe("GitHubExplore") {
    
    // MARK: curatedTopics

    it("curatedTopics") {
      // Arrange
      let jack = Jack("Test.GitHubExplore.curatedTopics")

      // Act, Assert
      waitUntil { done in
        _ = GitHubExplore.curatedTopics(aftreSync: false)
          .subscribe(
            onSuccess: { topics in
              jack.descendant("onSuccess").info("Found \(topics.count) curated topics")
              done()
            },
            onError: { error in
              jack.descendant("onError").error(Jack.dump(of: error))
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
      waitUntil { done in
        _ = GitHubExplore.collections(afterSync: false)
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
