import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit
fileprivate let jack = Jack()

extension Jack {
  static let service = Jack("Service")
}

/// Set `$HTTP_STUBBING` to 'YES' to enabled stubbing.
fileprivate var isStubbingEnabled: Bool = {
  let environValue = ProcessInfo.processInfo.environment["HTTP_STUBBING"] ?? "NO"
  let enabled = (environValue == "YES")

  if enabled {
    Jack.service.debug("""
    OHHTTPStubs is enabled ($HTTP_STUBBING == YES)
    """, options: [.compact, .noLocation])
  } else {
    Jack.service.debug("""
    OHHTTPStubs is NOT enabled ($HTTP_STUBBING != YES)
    """, options: [.compact, .noLocation])
  }

  return enabled
}()

fileprivate func setupStub() {
  guard isStubbingEnabled else { return }

  OHHTTPStubs.onStubActivation { request, stub, _ in
    Jack("OHHTTPStubs").debug("""
    hit : \(request)
    by  : \(stub.name ?? "<anonymous stub>")
    """)
  }
  OHHTTPStubs.onStubMissing { request in
    Jack("OHHTTPStubs").warn("""
    miss hit test: \(request.httpMethod!) - \(request.url!)"
    """)
  }
}

@discardableResult
fileprivate func stubIfEnabled(
  name: String,
  condition: @escaping OHHTTPStubsTestBlock
)
  -> OHHTTPStubsDescriptor?
{
  if isStubbingEnabled {
    let s = stub(
      condition: condition,
      response: { _ in OHHTTPStubsResponse(filename: "\(name).txt") }
    )
    s.name = name
    return s
  } else {
    return nil
  }
}

class ServiceSpec: QuickSpec {
  override func spec() {
    let timeout: TimeInterval = 5

    beforeEach {
      Jack.formattingOptions = [.noLocation]
      setupStub()
    }

    afterEach {
      OHHTTPStubs.removeAllStubs()
    }

    describe("OHHTTPStubs") {
      it("parse HTTP message file") {
        // Arrange
        let jack = Jack("OHHTTPStubs")

        let responseStub = OHHTTPStubsResponse(
          filename: "zen.txt"
        )

        expect(responseStub.statusCode) == 200
        let headers = responseStub.httpHeaders as! [String: String]
        expect(headers.count) > 0
        jack.verbose(Jack.dump(of: headers))

        jack.debug("data size: \(responseStub.dataSize)")
      }
    }

    // MARK: - Service.Misc

    describe("Service.Misc") {

      // MARK: zen

      it("zen") {
        // Arrange
        let jack = Jack("Service.user")

        stubIfEnabled(
          name: "zen",
          condition: isMethodGET() && isPath("/zen")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.zen().subscribe(
            onSuccess: { zen in
              jack.info("GitHub Zen: \(zen)")
              done()
            },
            onError: { jack.error(Jack.dump(of: $0)); fatalError() }
          )
        }
      }

      // MARK: rateLimit

      it("rateLimit") {
        // Arrange
        let jack = Jack("Service.rateLimit")

        stubIfEnabled(
          name: "rateLimit",
          condition: isMethodGET() && isPath("/rate_limit")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.rateLimit().subscribe(
            onSuccess: { rateLimit in
              jack.info(Jack.dump(of: rateLimit))
              done()
            },
            onError: { jack.error(Jack.dump(of: $0)); fatalError() }
          )
        }
      }

    } // describe("Misc")

    // MARK: - Service.Search

    describe("Service.Search") {

      // MARK: searchRepository

      it("searchRepository") {
        // Arrange
        let jack = Jack("Service.search")

        for index in 0 ..< 4 {
          stubIfEnabled(
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

    } // describe("Service.Search")

    // MARK: - Service.User

    describe("Service.User") {

      // MARK: currentUser

      it("currentUser") {
        // Arrange
        let jack = Jack("Service.currentUser")

        stubIfEnabled(
          name: "currentUser",
          condition: isMethodGET() && isPath("/user")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.currentUser().subscribe(
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

      // MARK: user

      it("user") {
        // Arrange
        let jack = Jack("Service.user")

        stubIfEnabled(
          name: "user",
          condition: isMethodGET() && pathStartsWith("/users")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.user(name: "mudox").subscribe(
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

      // MARK: isFollowing

      it("isFollowing") {
        // Arrange
        let jack = Jack("Service.isFollowing")

        stubIfEnabled(
          name: "isFollowing",
          condition: isMethodGET() && pathMatches("^/users/.*/following/")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.isFollowing(from: "tracy", to: "mudox")
            .subscribe(
              onSuccess: { response in
                jack.info("""
                Is tracy following mudox?
                \(Jack.dump(of: response))
                \(Jack.dump(of: response.payload))
                """)
                done()
              },
              onError: { jack.error(Jack.dump(of: $0)); fatalError() }
            )
        }

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.isFollowing(from: "mudox", to: "kevinzhow")
            .subscribe(
              onSuccess: { response in
                jack.info("""
                Is mudox following kevinzhow?
                  \(Jack.dump(of: response))
                  \(Jack.dump(of: response.payload))
                """)
                done()
              },
              onError: { jack.error(Jack.dump(of: $0)); fatalError() }
            )
        }
      }

    } // describe("Service.User")

    // MARK: - Service.Authorization

    describe("Service.Authoriztion") {
      // MARK: authorize

      it("authorize") {
        // Arrange
        let jack = Jack("Service.authorize")

        stubIfEnabled(
          name: "authorize",
          condition: isMethodPOST() && isPath("/authorizations")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.authorize().subscribe(
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

      // MARK: authorizations

      it("authorizations") {
        // Arrange
        let jack = Jack("Service.authorizations")

        stubIfEnabled(
          name: "authorizations",
          condition: isMethodGET() && isPath("/authorizations")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.authorizations().subscribe(
            onSuccess: { response in
              let hydraAuths = response.payload
                .filter { $0.app.name == "Hydra" }
                .enumerated()
                .map { index, auth in
                  """
                  [\(index)]
                  - id           : \(auth.id)
                  - note         : \(auth.note ?? "n/a")
                  - created      : \(auth.creationDate)
                  - fingerprint  : \(auth.fingerprint ?? "n/a")
                  - scopes       : \(auth.scopes.sorted().joined(separator: " | "))
                  """
                }.joined(separator: "\n")

              jack.info("""
              \(Jack.dump(of: response))
              Total: \(response.payload.count), authorizations of Hydra:
              \(hydraAuths)
              """)
              done()
            },
            onError: { jack.error(Jack.dump(of: $0)); fatalError() }
          )
        }
      }

      // MARK: deleteAuthorization

      it("deleteAuthorization") {
        // Arrange
        let jack = Jack("Service.deleteAuthorization")

        stubIfEnabled(
          name: "deleteAuthorization",
          condition: isMethodDELETE() && pathStartsWith("/authorizations")
        )

        stubIfEnabled(
          name: "authorizations",
          condition: isMethodGET() && isPath("/authorizations")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          let id = 217_869_482
          _ = Service.shared.deleteAuthorization(id: id).subscribe(
            onCompleted: {
              jack.info("deleted authorization with ID: \(id)")
            },
            onError: { jack.error(Jack.dump(of: $0)); fatalError() }
          )
          _ = Service.shared.authorizations().subscribe(
            onSuccess: { response in
              let hydraAuths = response.payload
                .filter { $0.app.name == "Hydra" }
                .enumerated()
                .map { index, auth in
                  """
                  [\(index)]
                  - id           : \(auth.id)
                  - note         : \(auth.note ?? "n/a")
                  - created      : \(auth.creationDate)
                  - fingerprint  : \(auth.fingerprint ?? "n/a")
                  - scopes       : \(auth.scopes.sorted().joined(separator: " | "))
                  """
                }
                .joined(separator: "\n")

              jack.info("""
              \(Jack.dump(of: response))
              Total: \(hydraAuths.count) authorizations of Hydra:
              \(hydraAuths)
              """)
              done()
            },
            onError: { jack.error(Jack.dump(of: $0)); fatalError() }
          )
        }
      }

      // MARK: grants

      it("grants") {
        // Arrange
        let jack = Jack("Service.grants")

        stubIfEnabled(
          name: "grants",
          condition: isMethodGET() && isPath("/applications/grants")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.grants().subscribe(
            onSuccess: { response in
              let list = response.payload
                .enumerated()
                .map { index, grant in
                  """
                  [\(index)]
                  - id      : \(grant.id)
                  - app     : \(grant.app.name)
                  - scopes  : \(grant.scopes.sorted().joined(separator: " | "))
                  """
                }
                .joined(separator: "\n")

              jack.info("""
              \(Jack.dump(of: response))
              Total: \(response.payload.count)
              \(list)
              """)
              done()
            },
            onError: { jack.error(Jack.dump(of: $0)); fatalError() }
          )
        }
      }

      // MARK: deleteGrant

      it("deleteGrant") {
        // Arrange
        let jack = Jack("Service.deleteGrant")

        stubIfEnabled(
          name: "grants",
          condition: isMethodDELETE() && pathStartsWith("/applications/grants")
        )

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          let id = 73_626_521
          _ = Service.shared.deleteGrant(id: id).subscribe(
            onCompleted: {
              jack.info("deleted grant with ID: \(id)")
            },
            onError: { jack.error(Jack.dump(of: $0)); done() }
          )
          _ = Service.shared.grants().subscribe(
            onSuccess: { response in
              let list = response.payload
                .enumerated()
                .map { index, grant in
                  """
                  [\(index)]
                  - id      : \(grant.id)
                  - app     : \(grant.app.name)
                  - scopes  : \(grant.scopes.sorted().joined(separator: " | "))
                  """
                }
                .joined(separator: "\n")

              jack.info("""
              \(Jack.dump(of: response))
              Total: \(response.payload.count)
              \(list)
              """)
              done()
            },
            onError: { jack.error(Jack.dump(of: $0)); fatalError() }
          )
        }
      }

    } // describe("Service.Authorization")

    // MARK: - Service.GitData

    fdescribe("Service.GitData") {

      // MARK: reference

      it("reference") {
        // Arrange
        let jack = Jack("Service.reference")

        stubIfEnabled(
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

        stubIfEnabled(
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

        stubIfEnabled(
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

        stubIfEnabled(
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

    } // describe("Service")
  } // spec()
}
