import XCTest

import Nimble
import Quick

import GitHubKit

import JacKit
fileprivate let jack = Jack()

func onError(_ error: Error, file: StaticString = #file, line: UInt = #line) -> Never {
  jack.error(Jack.dump(of: error))
  fatalError(file: file, line: line)
}

class ServiceSpec: QuickSpec { override func spec() {

  let timeout: TimeInterval = 5

  beforeEach {
    Jack.formattingOptions = [.noLocation]
  }

  describe("Service") {

    // MARK: searchRepository

    it("searchRepository") {
      // Arrange
      let jack = Jack("Service.search")

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
        let id = 73626521
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
} }
