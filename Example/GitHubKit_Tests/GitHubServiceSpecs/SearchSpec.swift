import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class SearchSpec: QuickSpec { override func spec() {

  beforeEach {
    Jack.defaultOptions = [.noLocation]
    NetworkStubbing.setup()
  }

  afterEach {
    OHHTTPStubs.removeAllStubs()
  }

  // MARK: searchRepository

  it("searchRepository") {
    // Arrange
    let jack = Jack("Service.search")

    for index in 0 ..< 4 {
      NetworkStubbing.stubIfEnabled(
        name: "search_repositories_\(index)",
        condition: isMethodGET() && isPath("/search/repositories")
      )

      // Act, Assert
      waitUntil(timeout: timeout) { done in
        _ = Service.shared.searchRepository("neovim").subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            Found \(response.payload.items.count) results
            """)

            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
      }
    }
  }

} }