import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHubKit

import JacKit

class AuthorizationSpec: QuickSpec { override func spec() {

  beforeEach {
    Jack.formattingOptions = [.noLocation]
    NetworkStubbing.setup()
  }

  afterEach {
    OHHTTPStubs.removeAllStubs()
  }

  // MARK: authorize

  it("authorize") {
    // Arrange
    let jack = Jack("Service.authorize")

    NetworkStubbing.stubIfEnabled(
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

    NetworkStubbing.stubIfEnabled(
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
    
    guard NetworkStubbing.isEnabled else {
      jack.warn("only run on netwokring stubbing being enabled, skip ...")
      return
    }

    NetworkStubbing.stubIfEnabled(
      name: "deleteAuthorization",
      condition: isMethodDELETE() && pathStartsWith("/authorizations")
    )

    // Act, Assert
    waitUntil(timeout: timeout) { done in
      let id = 1
      _ = Service.shared.deleteAuthorization(id: id).subscribe(
        onCompleted: {
          jack.info("deleted authorization with ID: \(id)")
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

    NetworkStubbing.stubIfEnabled(
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
    
    guard NetworkStubbing.isEnabled else {
      jack.warn("only run on netwokring stubbing being enabled, skip ...")
      return
    }

    NetworkStubbing.stubIfEnabled(
      name: "deleteGrant",
      condition: isMethodDELETE() && pathStartsWith("/applications/grants")
    )

    // Act, Assert
    waitUntil(timeout: timeout) { done in
      let id = 1
      _ = Service.shared.deleteGrant(id: id).subscribe(
        onCompleted: {
          jack.info("deleted grant with ID: \(id)")
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

} }
