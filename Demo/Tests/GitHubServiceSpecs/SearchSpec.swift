import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class SearchSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  // MARK: searchRepository

  it("searchRepository") {
    // Arrange
    let jack = Jack("Service.search")

    for index in 0 ..< 4 {
      HTTPStubbing.stubIfEnabled(
        name: "search_repositories_\(index)",
        condition: isMethodGET() && isPath("/search/repositories")
      )

      // Act, Assert
      waitUntil { done in
        _ = Fixtures.gitHubService.searchRepository("neovim").subscribe(
          onSuccess: { response in
            jack.info("""
            \(dump(of: response))
            Found \(response.payload.items.count) results
            """)

            done()
          },
          onError: { jack.error(dump(of: $0)); fatalError() }
        )
      }
    }
  }

} }
