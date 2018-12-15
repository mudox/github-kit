import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class GitHubLanguageSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  it("all") {
    // Arrange
    let jack = Jack("Test.GitHub.Language.all")

    HTTPStubbing.stubIfEnabled(
      name: "github-languages",
      condition: isMethodGET() && pathEndsWith("/languages.yml")
    )

    // Act, Assert
    waitUntil { done in
      _ = GitHub.Language.all
        .subscribe(
          onSuccess: { languages in
            languages[...4].forEach { language in
              jack.debug(dump(of: language))
            }
            done()
          },
          onError: { error in
            jack.error(dump(of: error))
            fatalError()
          }
        )
    }
  }

} }
