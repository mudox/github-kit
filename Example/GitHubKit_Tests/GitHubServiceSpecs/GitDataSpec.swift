import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class GitDataSpec: QuickSpec { override func spec() {

  beforeEach {
    Jack.defaultOptions = [.noLocation]
    NetworkStubbing.setup()
  }

  afterEach {
    OHHTTPStubs.removeAllStubs()
  }

  // MARK: reference

  it("reference") {
    // Arrange
    let jack = Jack("Service.reference")

    NetworkStubbing.stubIfEnabled(
      name: "reference",
      condition: isMethodGET() && pathMatches("^/repos/.*/git/refs/")
    )

    // Act, Assert
    waitUntil(timeout: timeout) { done in
      _ = Service.shared.reference(of: "github", "explore", withPath: "heads/master")
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            \(Jack.dump(of: response.payload))
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: commit

  it("commit") {
    // Arrange
    let jack = Jack("Service.commit")

    NetworkStubbing.stubIfEnabled(
      name: "commit",
      condition: isMethodGET() && pathMatches("^/repos/.*/git/commits/")
    )

    // Act, Assert
    waitUntil(timeout: timeout) { done in
      _ = Service.shared.commit(
        of: "github", "explore", withSHA: "04da4c2fa18043112ebcc8ca7e95fc14957f4aa1"
      )
      .subscribe(
        onSuccess: { response in
          jack.info("""
          \(Jack.dump(of: response))
          \(Jack.dump(of: response.payload))
          """)
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: tree

  it("tree") {
    // Arrange
    let jack = Jack("Service.tree")

    NetworkStubbing.stubIfEnabled(
      name: "tree",
      condition: isMethodGET() && pathMatches("^/repos/.*/git/trees/")
    )

    // Act, Assert
    waitUntil(timeout: timeout) { done in
      let sha = "4b66c5bf104ff7424da52d82c05cfb6a061b7d49"
      _ = Service.shared.tree(of: "github", "explore", withSHA: sha)
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            \(Jack.dump(of: response.payload))
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: blob

  it("blob") {
    // Arrange
    let jack = Jack("Service.blob")

    NetworkStubbing.stubIfEnabled(
      name: "blob",
      condition: isMethodGET() && pathMatches("^/repos/.*/git/blobs/")
    )

    // Act, Assert
    waitUntil(timeout: timeout) { done in
      let sha = "60c424465c52b757d9fca910ef2560e17ef0f626"
      _ = Service.shared.blob(of: "github", "explore", withSHA: sha)
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            \(Jack.dump(of: response.payload))
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

} }
