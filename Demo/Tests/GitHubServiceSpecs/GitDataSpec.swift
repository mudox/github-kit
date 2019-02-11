import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class GitDataSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)


  // MARK: reference

  it("reference") {
    // Arrange
    let jack = Jack("Test.Service.reference")

    HTTPStubbing.stubIfEnabled(
      name: "reference",
      condition: isMethodGET() && pathMatches("^/repos/.*/git/refs/")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.reference(of: "github", "explore", withPath: "heads/master")
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(dump(of: response))
            \(dump(of: response.payload))
            """)
            done()
          },
          onError: { jack.error(dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: commit

  it("commit") {
    // Arrange
    let jack = Jack("Test.Service.commit")

    HTTPStubbing.stubIfEnabled(
      name: "commit",
      condition: isMethodGET() && pathMatches("^/repos/.*/git/commits/")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.commit(
        of: "github", "explore", withSHA: "04da4c2fa18043112ebcc8ca7e95fc14957f4aa1"
      )
      .subscribe(
        onSuccess: { response in
          jack.info("""
          \(dump(of: response))
          \(dump(of: response.payload))
          """)
          done()
        },
        onError: { jack.error(dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: tree

  it("tree") {
    // Arrange
    let jack = Jack("Test.Service.tree")

    HTTPStubbing.stubIfEnabled(
      name: "tree",
      condition: isMethodGET() && pathMatches("^/repos/.*/git/trees/")
    )

    // Act, Assert
    waitUntil { done in
      let sha = "4b66c5bf104ff7424da52d82c05cfb6a061b7d49"
      _ = Fixtures.gitHubService.tree(of: "github", "explore", withSHA: sha)
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(dump(of: response))
            \(dump(of: response.payload))
            """)
            done()
          },
          onError: { jack.error(dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: blob

  it("blob") {
    // Arrange
    let jack = Jack("Test.Service.blob")

    HTTPStubbing.stubIfEnabled(
      name: "blob",
      condition: isMethodGET() && pathMatches("^/repos/.*/git/blobs/")
    )

    // Act, Assert
    waitUntil { done in
      let sha = "60c424465c52b757d9fca910ef2560e17ef0f626"
      _ = Fixtures.gitHubService.blob(of: "github", "explore", withSHA: sha)
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(dump(of: response))
            \(dump(of: response.payload))
            """)
            done()
          },
          onError: { jack.error(dump(of: $0)); fatalError() }
        )
    }
  }

} }
