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

func onError(_ error: Error, file: StaticString = #file, line: UInt = #line) -> Never {
  jack.error(Jack.dump(of: error))
  fatalError(file: file, line: line)
}

/// Set $NETWORK_STUBBING_ENABLED to 'YES' to enabled stubbing.
fileprivate var isStubbingEnabled: Bool = {
  let environValue = ProcessInfo.processInfo.environment["NETWORK_STUBBING_ENABLED"] ?? "NO"
  let enabled = (environValue == "YES")

  if enabled {
    Jack.service.debug("""
    OHHTTPStubs is enabled ($NETWORK_STUBBING_ENABLED=YES)
    """, options: [.compact, .noLocation])
  } else {
    Jack.service.debug("""
    OHHTTPStubs is NOT enabled ($NETWORK_STUBBING_ENABLED=NO)
    """, options: [.compact, .noLocation])
  }

  return enabled
}()

fileprivate func setupStub() {
  OHHTTPStubs.onStubActivation { request, stub, _ in
    Jack("OHHTTPStubs").debug("""
    hit : \(request)
    by  : \(stub.name ?? "<anonymous stub>")
    """)
  }
  OHHTTPStubs.onStubMissing { request in
    Jack("OHHTTPStubs").warn("""
    miss hit test: \(request)
    """)
  }
}

fileprivate func stubIfEnabled(
  condition: @escaping OHHTTPStubsTestBlock,
  response: @escaping OHHTTPStubsResponseBlock
)
  -> OHHTTPStubsDescriptor?
{
  if isStubbingEnabled {
    return stub(condition: condition, response: response)
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
          responseFileName: "search_repositories_3.txt",
          inBundleForClass: type(of: self)
        )

        expect(responseStub.statusCode) == 200
        let headers = responseStub.httpHeaders as! [String: String]
        expect(headers.count) > 0
        jack.verbose(Jack.dump(of: headers))

        jack.debug("data size: \(responseStub.dataSize)")
      }
    }

    describe("Service") {

      // MARK: searchRepository

      fit("searchRepository") {
        // Arrange
        let jack = Jack("Service.search")

        for index in 0 ..< 4 {
          stubIfEnabled(
            condition: isPath("/search/repositories"),
            response: { _ in
              OHHTTPStubsResponse(
                responseFileName: "search_repositories_\(index).txt",
                inBundleForClass: type(of: self)
              )
            }
          )?.name = "searchReposiories (search_repositories_\(index).txt"

          // Act, Assert
          waitUntil(timeout: timeout) { done in
            _ = Service.shared.searchRepository("neovim").subscribe(
              onSuccess: { response in
                jack.info("""
                \(Jack.dump(of: response))
                - - -
                Found \(response.payload.items.count) results
                """)

                done()
              },
              onError: { onError($0) }
            )
          }
        }
      }

      // MARK: - currentUser

      it("currentUser") {
        // Arrange
        let jack = Jack("Service.currentUser")

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.currentUser().subscribe(
            onSuccess: { response in
              jack.info("""
              \(Jack.dump(of: response))
              - - -
              Username: \(response.payload.name)
              """)
              done()
            },
            onError: { onError($0) }
          )
        }
      }

      // MARK: user

      it("user") {
        // Arrange
        let jack = Jack("Service.user")

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.user(name: "mudox").subscribe(
            onSuccess: { response in
              jack.info("""
              \(Jack.dump(of: response))
              - - -
              Username: \(response.payload.name)
              """)
              done()
            },
            onError: { onError($0) }
          )
        }
      }

      // MARK: - zen

      it("zen") {
        // Arrange
        let jack = Jack("Service.user")

        stubIfEnabled(
          condition: isPath("/zen"),
          response: { _ in
            OHHTTPStubsResponse(
              data: "Stubbed GitHub Zen".data(using: .utf8)!,
              statusCode: 200,
              headers: nil
            )
          }
        )?.name = "zen"

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.zen().subscribe(
            onSuccess: { zen in
              jack.info("GitHub Zen: \(zen)")
              done()
            },
            onError: { onError($0) }
          )
        }
      }

      // MARK: rateLimit

      it("rateLimit") {
        // Arrange
        let jack = Jack("Service.rateLimit")

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          _ = Service.shared.rateLimit().subscribe(
            onSuccess: { rateLimit in
              jack.info(Jack.dump(of: rateLimit))
              done()
            },
            onError: { onError($0) }
          )
        }
      }

      // MARK: - authorize

      xit("authorize") {
        // Arrange
        let jack = Jack("Service.authorize")

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
            onError: { onError($0) }
          )
        }
      }

      // MARK: authorizations

      it("authorizations") {
        // Arrange
        let jack = Jack("Service.authorizations")

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
            onError: { onError($0) }
          )
        }
      }

      // MARK: deleteAuthorization

      xit("deleteAuthorization") {
        // Arrange
        let jack = Jack("Service.deleteAuthorization")

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          let id = 217_869_482
          _ = Service.shared.deleteAuthorization(id: id).subscribe(
            onCompleted: {
              jack.info("deleted authorization with ID: \(id)")
            },
            onError: { onError($0) }
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
              Total: \(response.payload.count), authorizations of Hydra:
              \(hydraAuths)
              """)
              done()
            },
            onError: { onError($0) }
          )
        }
      }

      // MARK: - grants

      it("grants") {
        // Arrange
        let jack = Jack("Service.grants")

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
            onError: { onError($0) }
          )
        }
      }

      // MARK: deleteGrant

      xit("deleteGrant") {
        // Arrange
        let jack = Jack("Service.deleteGrant")

        // Act, Assert
        waitUntil(timeout: timeout) { done in
          let id = 73_626_521
          _ = Service.shared.deleteGrant(id: id).subscribe(
            onCompleted: {
              jack.info("deleted grant with ID: \(id)")
            },
            onError: { onError($0) }
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
            onError: { onError($0) }
          )
        }
      }

    } // describe("Service")
  } // spec()
}
