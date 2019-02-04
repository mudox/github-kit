import XCTest

import Nimble
import Quick

import OHHTTPStubs

@testable import GitHub

import JacKit

class GitHubExploreSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  it("loads topic and collection lists") {
    // Arrange
    let jack = Jack("Test.GitHub.Explore.lists")

    // Act, Assert
    waitUntil { done in
      _ = GitHub.Explore.lists
        .subscribe(
          onSuccess: { lists in
            jack.sub("onSuccess").info("""
            - Topics count: \(lists.topics.count)
            - Collections count: \(lists.collections.count)
            """)
            done()
          },
          onError: { error in
            jack.sub("onError").error(dump(of: error))
            fail()
          }
        )
    }
  }

} }
