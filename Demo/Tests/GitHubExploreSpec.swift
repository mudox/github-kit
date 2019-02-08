import XCTest

import Nimble
import Quick

import OHHTTPStubs

@testable import GitHub

import JacKit

class GitHubExploreSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  fit("loads topic and collection lists") {
    // Arrange
    let jack = Jack("Test.GitHub.Explore.lists").set(format: .short)

    // Act, Assert
    waitUntil { done in
      _ = GitHub.Explore.lists
        .subscribe(
          onNext: { state in
            switch state {
            case let .success(lists):
              jack.sub("onSuccess").info("""
              - Topics count: \(lists.topics.count)
              - Collections count: \(lists.collections.count)
              """)
              done()
            default:
              jack.func().debug("\(state)")
            }
          },
          onError: { error in
            jack.sub("onError").error(dump(of: error))
            fail()
          }
        )
    }
  }

} }
