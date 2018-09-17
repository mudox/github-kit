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
    
    it("test") {
      // Arrange
      let jack = Jack("GitHubExplore")

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubExplore.test()
          .subscribe(
            onSuccess: { topics in
              expect(topics.isEmpty) != true
              done()
            },
            onError: { error in
              jack.error("\(Jack.dump(of: error))")
              fatalError()
            }
          )
      }
    }

    it("CuratedTopic") {
      // Arrange
      let jack = Jack("CuratedTopic")

      // Act, Assert
      let url = Bundle.main.url(forResource: "explore_topic", withExtension: "txt")!
      expect {
        let topic = try CuratedTopic(indexFileURL: url)
        return topic
      }.toNot(throwError())
    }

  } // describe("GitHubExplore")

} }
