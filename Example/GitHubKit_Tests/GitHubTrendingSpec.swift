import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class GitHubTrendingSpec: QuickSpec { override func spec() {

  // MARK: downloadGitHubExplore

  describe("GitHubTrending") {

    beforeEach {
      NetworkStubbing.setup()
    }
    
    afterEach {
      OHHTTPStubs.removeAllStubs()
    }

//    it("lists trending repositories") {
//      // Arrange
//      let jack = Jack("test.githubtrending.repositories")
//
//      NetworkStubbing.stubIfEnabled(
//        name: "repository-trending",
//        condition: isMethodGET() && pathStartsWith("/trending")
//      )
//
//      // Act, Assert
//      waitUntil(timeout: timeout) { done in
//        _ = GitHubTrending.repositories(of: "swift", in: .pastMonth)
//          .subscribe(
//            onSuccess: { _ in
//              done()
//            },
//            onError: { error in
//              jack.error(Jack.dump(of: error))
//              fatalError()
//            }
//          )
//      }
//    }

    fit("lists trending developers") {
      // Arrange
      let jack = Jack("Test.GitHubTrending.developers(of:in)")

      NetworkStubbing.stubIfEnabled(
        name: "developer-trending",
        condition: isMethodGET() && pathStartsWith("/trending/developers")
      )

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubTrending.developers(of: "swift", in: .pastWeek)
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
