import XCTest

import Nimble
import Quick

import OHHTTPStubs

@testable import GitHub

import JacKit

class GitHubExploreSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  it("topicsAndCollections") {
    // Arrange
    let jack = Jack("Test.GitHub.Explore.topicsAndCollections")

    // Act, Assert
    waitUntil { done in
      _ = GitHub.Explore.topicsAndCollections
        .subscribe(
          onSuccess: { topics, collections in
            jack.descendant("onSuccess").info("""
            - Topics count: \(topics.count)
            - Collections count: \(collections.count)
            """)
            done()
          },
          onError: { error in
            jack.descendant("onError").error(dump(of: error))
            fatalError()
          }
        )
    }
  }

} }
