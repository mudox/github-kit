import XCTest

import Nimble
import Quick
import RxNimble

import OHHTTPStubs

@testable import GitHub

import JacKit

class AuthorizationSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  // MARK: authorize

  it("authorize") {
    // Arrange
    let jack = Jack("Test.Service.authorize")

    HTTPStubbing.stubIfEnabled(
      name: "authorize",
      condition: isMethodPOST() && isPath("/authorizations")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.authorize(scope: [.user, .repository]).subscribe(
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

  it("authorize invalid credentials") {
    // Arrange
    let jack = Jack("Test.Service.authorize.error.invalidCredential")

    HTTPStubbing.stubIfEnabled(
      name: "authorize_invalid_credential",
      condition: isMethodPOST() && isPath("/authorizations")
    )

    let credentials = Credentials(user: Credentials.invalidUser, app: Credentials.validApp)
    let service = GitHub.Service(credentials: credentials)

    // Act, Assert
    waitUntil { done in
      _ = service.authorize(scope: [.user, .repository]).subscribe(
        onSuccess: { response in
          jack.info("""
          \(dump(of: response))
          \(dump(of: response.payload))
          """)
          fatalError("expect to fail")
        },
        onError: { error in
          jack.info("error: \(dump(of: error))")
          if case GitHubError.invalidCredential = error {
            done()
          } else {
            fatalError()
          }
        }
      )
    }
  }

  it("authorize invalid request parameter") {
    // Arrange
    let jack = Jack("Test.Service.authorize.error.invalidRequestParameter")

    HTTPStubbing.stubIfEnabled(
      name: "authorize_invalid_parameter",
      condition: isMethodPOST() && isPath("/authorizations")
    )

    let credentials = Credentials(user: Credentials.validUser, app: Credentials.invalidApp)
    let service = GitHub.Service(credentials: credentials)

    // Act, Assert
    waitUntil { done in
      _ = service.authorize(scope: [.user, .repository]).subscribe(
        onSuccess: { response in
          jack.info("""
          \(dump(of: response))
          \(dump(of: response.payload))
          """)
          fatalError("expect to fail")
        },
        onError: { error in
          jack.info("error: \(dump(of: error))")
          if case GitHubError.invalidRequestParameter = error {
            done()
          } else {
            fatalError()
          }
        }
      )
    }
  }

  // MARK: authorizations

  it("authorizations") {
    // Arrange
    let jack = Jack("Test.Service.authorizations")

    HTTPStubbing.stubIfEnabled(
      name: "authorizations",
      condition: isMethodGET() && isPath("/authorizations")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.authorizations().subscribe(
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
          \(dump(of: response))
          Total: \(response.payload.count), authorizations of Hydra:
          \(hydraAuths)
          """)
          done()
        },
        onError: { jack.error(dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: deleteAuthorization

  it("deleteAuthorization") {
    // Arrange
    let jack = Jack("Test.Service.deleteAuthorization")

    guard HTTPStubbing.isEnabled else {
      jack.warn("only run on netwokring stubbing being enabled, skip ...")
      return
    }

    HTTPStubbing.stubIfEnabled(
      name: "deleteAuthorization",
      condition: isMethodDELETE() && pathStartsWith("/authorizations")
    )

    // Act, Assert
    waitUntil { done in
      let id = 1
      _ = Fixtures.gitHubService.deleteAuthorization(id: id).subscribe(
        onCompleted: {
          jack.info("deleted authorization with ID: \(id)")
          done()
        },
        onError: { jack.error(dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: grants

  it("grants") {
    // Arrange
    let jack = Jack("Test.Service.grants")

    HTTPStubbing.stubIfEnabled(
      name: "grants",
      condition: isMethodGET() && isPath("/applications/grants")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.grants().subscribe(
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
          \(dump(of: response))
          Total: \(response.payload.count)
          \(list)
          """)
          done()
        },
        onError: { jack.error(dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: deleteGrant

  it("deleteGrant") {
    // Arrange
    let jack = Jack("Test.Service.deleteGrant")

    guard HTTPStubbing.isEnabled else {
      jack.warn("only run on netwokring stubbing being enabled, skip ...")
      return
    }

    HTTPStubbing.stubIfEnabled(
      name: "deleteGrant",
      condition: isMethodDELETE() && pathStartsWith("/applications/grants")
    )

    // Act, Assert
    waitUntil { done in
      let id = 1
      _ = Fixtures.gitHubService.deleteGrant(id: id).subscribe(
        onCompleted: {
          jack.info("deleted grant with ID: \(id)")
          done()
        },
        onError: { jack.error(dump(of: $0)); fatalError() }
      )
    }
  }

} }
