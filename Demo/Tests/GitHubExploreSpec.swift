import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class GitHubExploreSpec: QuickSpec { override func spec() {
  
  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  describe("GitHub.Explore") {
    
    // MARK: curatedTopics

    it("curatedTopics") {
      // Arrange
      let jack = Jack("Test.GitHub.Explore.curatedTopics")

      // Act, Assert
      waitUntil { done in
        _ = GitHub.Explore.curatedTopics(aftreSync: false)
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
      let jack = Jack("Test.GitHub.Explore.collections")

      // Act, Assert
      waitUntil { done in
        _ = GitHub.Explore.collections(afterSync: false)
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

  } // describe("GitHub.Explore")

} }
