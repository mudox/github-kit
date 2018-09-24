import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class GitHubLanguageSpec: QuickSpec { override func spec() {

  beforeEach {
    NetworkStubbing.setup()
  }
  
  afterEach {
    OHHTTPStubs.removeAllStubs()
  }
  
  describe("GitHubLanguage") {


    it("lists all github languages") {
      // Arrange
      let jack = Jack("Test.GitHubLanguage.all")

      NetworkStubbing.stubIfEnabled(
        name: "github-languages",
        condition: isMethodGET() && pathEndsWith("/languages.yml")
      )

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = GitHubLanguage.all
          .subscribe(
            onSuccess: { languages in
              languages[...4].forEach { language in
                jack.debug(Jack.dump(of: language))
              }
              done()
            },
            onError: { error in
              jack.error(Jack.dump(of: error))
              fatalError()
            }
          )
      }
    }

    it("lists trending developers") {
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
